classdef CFIR
    % AD9084CFIR
    %   - Encapsulates CFIR-specific catalogs, defaults, validation, and file output.
    %   - Constructor accepts taps and (optional) params as struct or Name-Value pairs.
    %   - Always outputs HEX coefficients by calling FIRcoeff 
    %   - Header lines follow CFIR format, e.g.:
    %       dest: rx cfir_all profile_2 datapath_all
    %       gain: 0
    %       complex_scalar: 32767 0
    %       enable: 1 profile_2
    %       selection_mode: direct_regmap  % or: direct_gpio, trig_regmap, trig_gpio, trig_auto
    %       coeff_transfer: 0
    %       bypass: 0
    %
    % Notes
    %   * Taps are provided as a column vector (Nx1 double), like PFilt.
    %   * Each tap is duplicated per line (I/Q), emitting: "0xHHHH 0xHHHH".
    %   * Use the 'profile' parameter to control the "profile_N" tokens in
    %     'dest' and 'enable'. If 'dest'/'enable' are provided explicitly,
    %      your values are used as-is.

    properties
        taps (:,1) double        % Column vector of taps 
        params struct            % Normalized parameters (header fields, etc.)
    end

    properties (Access=private)
        validOptions struct
    end

    methods
        function obj = CFIR(taps, options)
            % Constructor: taps + Name-Value pairs
            arguments

            taps (:,1) double

            %profile Profile Number
            %   Profile index for the CFIR block. Used to auto-build
            %   'dest' and 'enable' header tokens (e.g., 'profile_2').
            options.profile          (1,1) double   = 2

            %gain Shift Gain (dB)
            %   Programmable gain block at the CFIR output. Ranges from
            %   -18 dB to +12 dB in 6 dB steps.
            %   Options: '-18', '-12', '-6', '0', '6', '12'
            options.gain             {mustBeText}   = "0"

            %complex_scalar Complex Scalar Multiplier
            %   16-bit signed [real, imag] pair applied as a complex
            %   multiplier after filtering. Normalized by 32767.
            %   [32767 0] = unity real, [0 32767] = 90 degree rotation.
            %   Range: each component [-32768, 32767].
            options.complex_scalar   (1,2) double   = [32767 0]

            %dest Destination
            %   Header destination string for the filter file.
            %   If empty, auto-built from profile (e.g., 'rx cfir_all profile_2 datapath_all').
            options.dest             {mustBeText}   = ""

            %enable Enable String
            %   Header enable string. If empty, auto-built from profile
            %   (e.g., '1 profile_2').
            options.enable           {mustBeText}   = ""

            %selection_mode Profile Selection Mode
            %   Controls how CFIR profiles are switched.
            %   Options: 'direct_regmap', 'direct_gpio', 'trig_regmap',
            %            'trig_gpio', 'trig_auto'
            options.selection_mode   {mustBeText}   = "direct_regmap"

            %coeff_transfer Coefficient Transfer
            %   Trigger coefficient transfer to hardware. '0' or '1'.
            options.coeff_transfer   {mustBeText}   = "0"

            %bypass Bypass
            %   Bypass the CFIR filter block. '0' = filter active, '1' = bypassed.
            options.bypass           {mustBeText}   = "0"

            %sparse_mode Sparse Mode
            %   Enable 128-tap sparse CFIR (16 non-zero taps selectable
            %   anywhere in the impulse response).
            %   0 = normal mode (max 16 taps), 1 = sparse mode (max 128 taps).
            options.sparse_mode      (1,1) double   {mustBeMember(options.sparse_mode,[0 1])} = 0
        end

      
        obj.taps = taps(:);

        % Validate tap count before anything else.
        % Normal mode: 16-tap complex. Sparse mode: up to 128 taps (16 non-zero).
        % sparse_mode is not yet merged into params here, so read it directly.
        isSparse = (options.sparse_mode == 1);
        maxTaps = 128 * isSparse + 16 * ~isSparse;
        if numel(obj.taps) > maxTaps
            modeLabels = ["normal","sparse"];
            error('CFIR: %d taps provided but max is %d (%s mode).', ...
                  numel(obj.taps), maxTaps, modeLabels(isSparse + 1));
        end

        % Build catalogs
        obj.validOptions = obj.buildCatalogs();

        % Convert Name‑Value struct to regular struct (PFilt-compatible)
        nv = namedargs2cell(options);
        userParams = struct(nv{:});

        % Merge defaults w/ user overrides
        defaults      = obj.defaultParams();
        obj.params    = obj.mergeStructs(defaults, userParams);

        % Fill in profile‑dependent header fields
        obj.params    = obj.finalizeHeaderTokens(obj.params);

        % Validate
        obj.validateAll();

        end

        function outfile = write(obj, outfile)
            % Write header + HEX taps (I/Q columns) to a .txt file (CFIR)
            arguments
                obj
                outfile (1,1) string
            end

            % Convert taps via FIRcoeff (handles real and complex)
            [hexI, hexQ] = FIRcoeff(obj.taps);

            % Build header lines (CFIR)
            headerLines = obj.previewHeader(); % returns string array

            % Write file
            fid = fopen(outfile, 'w');
            if fid < 0, error('Cannot open file for writing: %s', outfile); end
            cleaner = onCleanup(@() fclose(fid));

            % Header
            for i = 1:numel(headerLines)
                fprintf(fid, '%s\n', headerLines(i));
            end

            % Coefficients: 0xI 0xQ per line
            for i = 1:size(hexI, 1)
                fprintf(fid, '0x%s 0x%s\n', hexI(i,:), hexQ(i,:));
            end
        end

        function lines = previewHeader(obj)
            % Return CFIR header lines (string array) without writing a file
            p = obj.params;

            % Build CFIR header
            lines = [
                "dest: "            + p.dest
                "gain: "            + obj.normalizeList(p.gain, [])
                "complex_scalar: "  + obj.twoNumbers(p.complex_scalar)
                "enable: "          + p.enable
                "selection_mode: "  + string(p.selection_mode)
                "coeff_transfer: "  + obj.normalizeList(p.coeff_transfer, [])
                "bypass: "          + obj.normalizeList(p.bypass, [])
                "sparse_mode: "     + string(p.sparse_mode)
            ];
        end

        function [H, f] = response(obj, Fs, options)
            % Compute hardware frequency response with tap quantization,
            % shift gain, and complex scalar.
            %
            %   [H, f] = cf.response(Fs)              % nominal (no LUT)
            %   [H, f] = cf.response(Fs, useLUT=true) % auto-find latest LUT
            %   [H, f] = cf.response(Fs, lutFile="path/to/cfir_gain_lut.m")
            %   cf.response(Fs)                       % no output args -> plots
            arguments
                obj
                Fs (1,1) double
                options.N (1,1) double = 1024
                options.useLUT (1,1) logical = false
                options.lutFile (1,1) string = ""
            end

            % Quantize taps to Q15 (matches hardware fixed-point)
            taps_q = round(obj.taps * 2^15) / 2^15;

            % Compute FIR frequency response
            f_vec = linspace(-Fs/2, Fs/2, options.N).';
            [H_fir, ~] = freqz(taps_q, 1, f_vec, Fs);

            % Load LUT only if requested
            if options.useLUT || options.lutFile ~= ""
                lut = obj.loadLUT(options.lutFile);
            else
                lut = struct();
            end

            % Apply shift gain from LUT
            if ~isempty(fieldnames(lut)) && isfield(lut, 'shift_gain_sweep')
                programmed_gain = str2double(string(obj.params.gain));
                shift_gain_dB = interp1( ...
                    lut.shift_gain_sweep.shift_gain_values_dB, ...
                    lut.shift_gain_sweep.gain_dB, ...
                    programmed_gain, 'linear', 'extrap');
            else
                shift_gain_dB = str2double(string(obj.params.gain));
            end

            % Apply complex_scalar
            cs = (obj.params.complex_scalar(1) + 1i*obj.params.complex_scalar(2)) / 32767;

            % Combine
            H = H_fir * cs * 10^(shift_gain_dB/20);
            f = f_vec;

            % Plot if no output requested
            if nargout == 0
                H_dBFS = 20*log10(abs(H) / max(abs(H)) + eps);
                figure('Name', 'CFIR Hardware Response');
                plot(f/1e6, H_dBFS, 'b-', 'LineWidth', 1.2);
                hold on; grid on;
                xlabel('Frequency (MHz)'); ylabel('Magnitude (dBFS)');
                title(sprintf('CFIR Response (gain=%s dB, scalar=[%d %d])', ...
                    string(obj.params.gain), obj.params.complex_scalar(1), obj.params.complex_scalar(2)));
                clear H f;
            end
        end
    end

    methods (Access=private)
        function lut = loadLUT(~, lutFile)
            % Load CFIR gain LUT from explicit file path or auto-find latest.
            if lutFile ~= ""
                [~, fname] = fileparts(lutFile);
                addpath(fileparts(lutFile));
                lut = feval(fname);
                return;
            end
            % Auto-find most recent cfir_gain_lut.m
            cfirRoot = fullfile(fileparts(mfilename('fullpath')), ...
                '..', '..', '..', 'MATLAB', 'cfir_gain_study_results');
            if exist(cfirRoot, 'dir')
                runs = dir(fullfile(cfirRoot, 'run_*'));
                for k = numel(runs):-1:1
                    candidate = fullfile(runs(k).folder, runs(k).name, 'cfir_gain_lut.m');
                    if exist(candidate, 'file')
                        [~, fname] = fileparts(candidate);
                        addpath(fileparts(candidate));
                        lut = feval(fname);
                        return;
                    end
                end
            end
            lut = struct();
        end

        function validOptions = buildCatalogs(~)
            % ---------------- CFIR catalog ----------------
            %  enumerate allowed values

            % Gain adjustment block at CFIR output. Per AD9084 UG: ranges from
            % -18dB to +12dB in 6dB steps.
            validOptions.cfir.gain             = {'-18','-12','-6','0','6','12'};
            % selection_mode controls how CFIR profiles are switched (same enum
            % as NCO profile hopping, per AD9084 UG adi_apollo_cfir_profile_sel_mode_set):
            %   direct_regmap - Immediate hop via SPI write (default, normal use)
            %   direct_gpio   - Immediate hop on GPIO edge
            %   trig_regmap   - Scheduled hop via SPI, fires on next trigger
            %   trig_gpio     - Scheduled hop via GPIO, fires on next trigger
            %   trig_auto     - Automatic increment/decrement hop on each trigger
            validOptions.cfir.selection_mode   = {'direct_regmap', 'direct_gpio', ...
                                                   'trig_regmap', 'trig_gpio', 'trig_auto'};
            validOptions.cfir.coeff_transfer   = {'0','1'};
            validOptions.cfir.bypass           = {'0','1'};
            % complex_scalar is numeric [real imag] -> validated structurally
            % dest/enable strings validated structurally; auto-build from profile if empty
        end

        function defaults = defaultParams(~)
            % CFIR defaults + profile drives dest/enable if those are empty.
            defaults = struct( ...
                'gain',             "0", ...
                'complex_scalar',   [32767, 0], ...
                'selection_mode',   "direct_regmap", ...
                'coeff_transfer',   "0", ...
                'bypass',           "0", ...
                'sparse_mode',      0, ...   % 0 = normal (16-tap), 1 = sparse (up to 128-tap, 16 non-zero)
                'profile',          2, ...   % used to generate "profile_N" in dest/enable
                'dest',             "", ...  % auto-built if empty
                'enable',           "" ...   % auto-built if empty
                );
        end

        function params = finalizeHeaderTokens(~, params)
            % Build "dest" and "enable" strings using the provided profile, if blank
            profTok = sprintf('profile_%d', params.profile);

            if strlength(string(params.dest)) == 0
                params.dest = "rx cfir_all " + profTok + " datapath_all";
            end
            if strlength(string(params.enable)) == 0
                params.enable = "1 " + profTok;
            end

            % Normalize complex_scalar to numeric 1x2
            cs = params.complex_scalar;
            if ~isnumeric(cs) || numel(cs) ~= 2
                error("CFIR: 'complex_scalar' must be a numeric 1x2 like [32767 0].");
            end
            params.complex_scalar = double(cs(:).'); % row [r i]
        end

        function validateAll(obj)
            p = obj.params;

            % complex_scalar: each component is a 16-bit signed integer [-32768, 32767]
            cs = p.complex_scalar;
            if ~isnumeric(cs) || numel(cs) ~= 2
                error("CFIR: 'complex_scalar' must be a numeric 1x2 like [32767 0].");
            end
            if any(cs < -32768) || any(cs > 32767) || any(cs ~= floor(cs))
                error("CFIR: 'complex_scalar' components must be integers in [-32768, 32767]. Got [%g %g].", cs(1), cs(2));
            end

            % gains
            obj.assertListMembership(p.gain, string(obj.validOptions.cfir.gain), "Gain", "cfir");

            % selection_mode
            if ~ismember(string(p.selection_mode), string(obj.validOptions.cfir.selection_mode))
                error("Invalid selection_mode '%s' for CFIR.", string(p.selection_mode));
            end

            % coeff_transfer
            obj.assertListMembership(p.coeff_transfer, string(obj.validOptions.cfir.coeff_transfer), "coeff_transfer", "cfir");

            % bypass
            obj.assertListMembership(p.bypass, string(obj.validOptions.cfir.bypass), "bypass", "cfir");

            % dest / enable: structural check only (allow user overrides)
            mustBeTextScalar = @(s) ischar(s) || (isstring(s) && isscalar(s));
            if ~(mustBeTextScalar(p.dest) && contains(string(p.dest), "cfir_all") && contains(string(p.dest), "profile_"))
                % Doesn't hard fail on exact token order, but warn user via error if it's too off
            end
            if ~(mustBeTextScalar(p.enable) && contains(string(p.enable), "profile_"))
            end
        end

        function assertListMembership(~, val, allowed, label, ~)
            % Accept scalar or space-separated list / string array / cellstr / numeric vector
            if iscellstr(val) || (isstring(val) && numel(val) > 1)
                if ~all(ismember(string(val), allowed))
                    error("Invalid %s values.", label);
                end
            elseif (ischar(val) || isstring(val))
                toks = split(strtrim(string(val)));
                toks = toks(toks ~= "");
                if ~all(ismember(toks, allowed))
                    error("Invalid %s '%s'.", label, string(val));
                end
            elseif isnumeric(val)
                if ~all(ismember(string(val(:).'), allowed))
                    error("Invalid numeric %s values.", label);
                end
            else
                error("Unsupported %s type.", label);
            end
        end

        function s = normalizeList(~, val, ~)
            % Returns a single space-separated string 
            if isstring(val) || ischar(val)
                txt = strtrim(string(val));
                if contains(txt, " ")
                    s = txt; % already tokenized
                    return;
                else
                    list = txt;
                end
            elseif iscellstr(val)
                list = string(val);
            elseif isstring(val) && numel(val) > 1
                list = val;
            elseif isnumeric(val)
                if isscalar(val)
                    list = string(val);
                else
                    list = string(val(:).');
                end
            else
                list = string(val);
            end
            s = strjoin(list, " ");
        end

        function s = twoNumbers(~, v)
            % Format [a b] as "a b"
            s = sprintf('%g %g', v(1), v(2));
            s = string(s);
        end

        function R = mergeStructs(~, A, B)
            R = A;
            fn = fieldnames(B);
            for k = 1:numel(fn)
                R.(fn{k}) = B.(fn{k});
            end
        end
    end
end