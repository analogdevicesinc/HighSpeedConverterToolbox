classdef PFilt
    % AD9084PFIR
    %   - Encapsulates PFIR-specific catalogs, defaults, validation, and file output.
    %   - Constructor accepts taps and Name-Value pairs (editor will suggest names).
    %   - Infers PFIR mode(s) from taps length if 'mode' is empty.
    %   - Always outputs HEX coefficients by calling FIRcoeff 

    %   * Use the 'profile' parameter to control the "profile_N" tokens in
    %     'dest' and 'enable'. If 'dest'/'enable' are provided explicitly,
    %     values are used as-is.

    properties
        taps (:,1) double        % Column vector of taps
        params struct            % Normalized parameters (header fields, etc.)
        modeTokens (1,2) string  % Two PFIR path tokens (one per path)
    end

    properties (SetAccess=private)
        TapLength (1,1) double   % Effective N = min(N1, N2) for the two paths
    end

    properties (Access=private)
        validOptions struct
        modeDefaults struct
    end

    methods
        function obj = PFilt(taps, options)
            % Constructor: taps + Name-Value pairs
            arguments
                taps (:,1) double

                %mode PFIR Filter Mode
                %   Determines the PFIR operating mode and max taps per path.
                %   Options: 'matrix', 'half_complex', 'real_n2', 'real_n4', 'disabled'
                %   If empty, mode is inferred from tap length.
                options.mode               {mustBeText}   = ""

                %gain Shift Gain (dB)
                %   Programmable gain block at the PFIR output. Ranges from
                %   0 dB to 24 dB in 6 dB steps. Applied after FIR filtering.
                %   Options: '0', '6', '12', '18', '24'
                options.gain               {mustBeText}   = "0"

                %scalar_gain Scalar Gain
                %   6-bit unsigned integer (0 to 63). Represents a fractional
                %   multiplier of N/64. 0 = silence, 63 = unity. Max scalar
                %   gain (63) and max shift gain (24 dB) cannot be used together.
                options.scalar_gain        {mustBeText}   = "0"

                %dest Destination
                %   Header destination string for the filter file.
                %   If empty, auto-built as 'rx pfilt_all bank_0'.
                options.dest               {mustBeText}   = ""

                %hc_delay Half-Complex Delay
                %   Delay setting for half-complex mode. Options: '0','1','2','3'
                options.hc_delay           {mustBeText}   = "0"

                %mode_switch_en Mode Switch Enable
                %   Enable dynamic mode switching between PFIR profiles. 0 or 1.
                options.mode_switch_en     (1,1) double   {mustBeMember(options.mode_switch_en, [0 1])} = 0

                %mode_switch_add_en Mode Switch Add Enable
                %   Enable additive mode switching. 0 or 1.
                options.mode_switch_add_en (1,1) double   {mustBeMember(options.mode_switch_add_en, [0 1])} = 0

                %real_data_mode_en Real Data Mode Enable
                %   When 1, PFIR operates on real data. When 0, complex data. Default 1.
                options.real_data_mode_en  (1,1) double   {mustBeMember(options.real_data_mode_en,[0 1])} = 1

                %quad_mode_en Quadrature Mode Enable
                %   Enable quadrature (I/Q correction) mode. 0 or 1.
                options.quad_mode_en       (1,1) double   {mustBeMember(options.quad_mode_en,   [0 1])} = 0

                %repeatCount Repeat Count
                %   Number of times to replicate gain/scalar_gain values in the
                %   header when a scalar value is provided. Matches path count.
                options.repeatCount        (1,1) double   = 4

                %profile Profile Number
                %   Profile index used to auto-build the 'dest' header token.
                options.profile            (1,1) double   = 2
            end

            % Store taps as column
            obj.taps = taps(:);

            % Build catalogs (PFIR)
            [obj.validOptions, obj.modeDefaults] = obj.buildCatalogs();

            % Convert Name-Value struct to a plain struct 
            nv = namedargs2cell(options);
            userParams = struct(nv{:});

            % Merge defaults -> user overrides
            defaults   = obj.defaultParams();
            obj.params = obj.mergeStructs(defaults, userParams);

            %for clarity 
            obj.params.type = "pfir";

            % Fill in profile-dependent header tokens (dest) if empty
            obj.params = obj.finalizeHeaderTokens(obj.params);

            % Infer / finalize mode tokens, ensure tap-length fit
            [obj.modeTokens, obj.params, obj.TapLength] = ...
                obj.inferModesAndTapLength(obj.taps, obj.params);

            % Validate all header options for PFIR
            obj.validateAll();
        end

        function outfile = write(obj, outfile)
            % Write header + HEX taps to a .txt file (PFIR)
            arguments
                obj
                outfile (1,1) string
            end

            % Convert taps to hex via FIRcoeff (handles real and complex)
            [hexI, ~] = FIRcoeff(obj.taps);

            % Build header lines
            rep = obj.params.repeatCount;
            headerLines = [
                "mode: "               + obj.normalizeList(obj.params.mode, [])
                "gain: "               + obj.normalizeList(obj.params.gain, rep)
                "scalar_gain: "        + obj.normalizeList(obj.params.scalar_gain, rep)
                "dest: "               + obj.normalizeList(obj.params.dest, [])
                "hc_delay: "           + string(obj.params.hc_delay)
                "mode_switch_en: "     + string(obj.params.mode_switch_en)
                "mode_switch_add_en: " + string(obj.params.mode_switch_add_en)
                "real_data_mode_en: "  + string(obj.params.real_data_mode_en)
                "quad_mode_en: "       + string(obj.params.quad_mode_en)
            ];

            % Write file
            fid = fopen(outfile, 'w');
            if fid < 0, error('Cannot open file for writing: %s', outfile); end
            cleaner = onCleanup(@() fclose(fid));

            % Header
            for i = 1:numel(headerLines)
                fprintf(fid, '%s\n', headerLines(i));
            end

            % Taps: PFIR expects one column; write one word per line as hex
            for i = 1:size(hexI, 1)
                fprintf(fid, '0x%s\n', hexI(i,:));
            end
        end

        function lines = previewHeader(obj)
            % Return header lines (string array) without writing a file
            rep = obj.params.repeatCount;
            lines = [
                "mode: "               + obj.normalizeList(obj.params.mode, [])
                "gain: "               + obj.normalizeList(obj.params.gain, rep)
                "scalar_gain: "        + obj.normalizeList(obj.params.scalar_gain, rep)
                "dest: "               + obj.normalizeList(obj.params.dest, [])
                "hc_delay: "           + string(obj.params.hc_delay)
                "mode_switch_en: "     + string(obj.params.mode_switch_en)
                "mode_switch_add_en: " + string(obj.params.mode_switch_add_en)
                "real_data_mode_en: "  + string(obj.params.real_data_mode_en)
                "quad_mode_en: "       + string(obj.params.quad_mode_en)
            ];
        end

        function [H, f] = response(obj, Fs, options)
            % Compute hardware frequency response with tap quantization,
            % shift gain, and scalar gain.
            %
            %   [H, f] = pf.response(Fs)              % nominal (no LUT)
            %   [H, f] = pf.response(Fs, useLUT=true) % auto-find latest LUT
            %   [H, f] = pf.response(Fs, lutFile="path/to/gain_lut.m")
            %   pf.response(Fs)                       % no output args -> plots
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

            % Apply scalar gain from LUT
            if ~isempty(fieldnames(lut)) && isfield(lut, 'scalar_sweep')
                programmed_scalar = str2double(string(obj.params.scalar_gain));
                scalar_gain_dB = interp1( ...
                    lut.scalar_sweep.scalar_values, ...
                    lut.scalar_sweep.gain_dB, ...
                    programmed_scalar, 'linear', 'extrap');
            else
                programmed_scalar = str2double(string(obj.params.scalar_gain));
                scalar_gain_dB = 20*log10(programmed_scalar / 64 + eps);
            end

            % Combine
            total_gain_linear = 10^(shift_gain_dB/20) * 10^(scalar_gain_dB/20);
            H = H_fir * total_gain_linear;
            f = f_vec;

            % Plot if no output requested
            if nargout == 0
                H_dBFS = 20*log10(abs(H) / max(abs(H)) + eps);
                figure('Name', 'PFilt Hardware Response');
                plot(f/1e9, H_dBFS, 'b-', 'LineWidth', 1.2);
                hold on; grid on;
                xlabel('Frequency (GHz)'); ylabel('Magnitude (dBFS)');
                title(sprintf('PFilt Response (gain=%s dB, scalar=%s)', ...
                    string(obj.params.gain), string(obj.params.scalar_gain)));
                clear H f;
            end
        end
    end

    methods (Access=private)
        function lut = loadLUT(~, lutFile)
            % Load PFIR gain LUT from explicit file path or auto-find latest.
            if lutFile ~= ""
                [~, fname] = fileparts(lutFile);
                addpath(fileparts(lutFile));
                lut = feval(fname);
                return;
            end
            % Auto-find most recent gain_lut.m
            resultsRoot = fullfile(fileparts(mfilename('fullpath')), ...
                '..', '..', '..', 'MATLAB', 'gain_study_results');
            if exist(resultsRoot, 'dir')
                runs = dir(fullfile(resultsRoot, 'run_*'));
                for k = numel(runs):-1:1
                    candidate = fullfile(runs(k).folder, runs(k).name, 'gain_lut.m');
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

        function [validOptions, modeDefaults] = buildCatalogs(~)
            % ---------------- PFIR catalog ----------------
            validOptions.pfir.modes              = {'matrix','half_complex','real_n2','real_n4','disabled'};

            % Shift gain: programmable gain block at the output of each FIR filter.
            % Ranges from 0dB to 24dB in 6dB steps only. Negative values are not
            % supported on the AD9084. (AD9084 UG: "The shift gain ranges from 0dB
            % to 24dB, in 6dB steps.")
            validOptions.pfir.gain               = {'0','6','12','18','24'};

            % Scalar gain: 6-bit unsigned integer written to the PFIR gain block.
            % Represents a fractional multiplier: value N yields gain of N/64.
            % Range: 0 (= 0/64, silence) to 64 (= 64/64 = 1, unity), integer steps.
            % NOTE: The maximum scalar gain (64) and maximum shift gain (24dB) cannot
            % be used together per the AD9084 UG. Max achievable gain is (63/64)*24dB.
            validOptions.pfir.scalar_gain        = arrayfun(@num2str, 0:64, 'UniformOutput', false);
            validOptions.pfir.dest               = {''};   % user override or auto-built from profile
            validOptions.pfir.hc_delay           = {'0','1','2','3'};
            validOptions.pfir.mode_switch_en     = {'0','1'};
            validOptions.pfir.mode_switch_add_en = {'0','1'};
            validOptions.pfir.real_data_mode_en  = {'0','1'};
            validOptions.pfir.quad_mode_en       = {'0','1'};

            % TapLength (N) per mode (per path) 
            modeDefaults.pfir.matrix       = struct('N',  16);
            modeDefaults.pfir.half_complex = struct('N', 16);
            modeDefaults.pfir.real_n2      = struct('N', 16);
            modeDefaults.pfir.real_n4      = struct('N', 32);
            modeDefaults.pfir.disabled     = struct('N', 16);
        end

        function defaults = defaultParams(~)
            % Reasonable PFIR defaults; most users won't need to pass these.
            defaults = struct( ...
                'type',               "pfir", ...
                'mode',               "", ...               % inferred if empty
                'gain',               "0", ...
                'scalar_gain',        "0", ...
                'dest',               "", ...               % auto-built if empty and profile given
                'hc_delay',           "0", ...
                'mode_switch_en',     0, ...
                'mode_switch_add_en', 0, ...
                'real_data_mode_en',  1, ...
                'quad_mode_en',       0, ...
                'repeatCount',        2, ...                % replicate gain/scalar_gain when scalar
                'profile',            2 ...                 % to mirror CFIR's auto-fill behavior
                );
        end

        % function params = finalizeHeaderTokens(~, params)
        %     % If 'dest' is empty, build one 
        %     % Example: "rx pfir_all profile_2 datapath_all"
        %     if strlength(string(params.dest)) == 0 && ~isempty(params.profile)
        %         profTok = sprintf('profile_%d', params.profile);
        %         params.dest = "rx pfir_all " + profTok + " datapath_all";
        %     end
        % end

        function params = finalizeHeaderTokens(~, params)
            % PFIR dest does not use a profile token (unlike CFIR).
            % Build default dest only if the user left it empty.
            destStr = strtrim(string(params.dest));
            if strlength(destStr) == 0
                params.dest = "rx pfilt_all bank_0";
            end
        end

        function [modeTokens, params, N_eff] = inferModesAndTapLength(obj, taps, params)
            % Determine two PFIR path modes from taps and/or provided hints.
            %
            % Strategy:
            %  - If params.mode has 0/1/2 tokens, normalize to two.
            %  - If absent, infer from taps length:
            %       L <= 8   -> matrix matrix
            %       9..16    -> half_complex half_complex
            %       17..32   -> real_n4 real_n4
            %       >32      -> error (PFIR defaults max at 32)
            %  - Enforce taps length <= min(N1, N2).

            toks = obj.tokenizeModes(params.mode);

            % auto inference if none provided
            if numel(toks)==0
                L = numel(taps);
                if L <= 8
                    toks = ["matrix","matrix"];
                elseif L <= 16
                    toks = ["real_n2","real_n2"];
                elseif L <= 32
                    toks = ["real_n4","real_n4"];
                else
                    error('Tap length %d exceeds PFIR maximum supported by defaults (N<=32).', L);
                end
                params.mode = strjoin(toks," ");
            elseif numel(toks)==1
                toks = [toks, toks];     % duplicate single token across both paths
                params.mode = strjoin(toks," ");
            elseif numel(toks)~=2
                error("Provide zero, one, or two mode tokens (one per path). Got: %s", strjoin(toks," "));
            end

            % Compute TapLength for each path and enforce
            try
                N1 = obj.modeDefaults.pfir.(toks(1)).N;
                N2 = obj.modeDefaults.pfir.(toks(2)).N;
            catch
                error("PFIR mode defaults not defined for token(s): %s", strjoin(toks," "));
            end

            N_eff = min([N1, N2]);
            if numel(taps) > N_eff
                error("Max possible taps across both PFIR paths is %d (path1 N=%d, path2 N=%d).", N_eff, N1, N2);
            end

            modeTokens = toks;
        end

        function validateAll(obj)
            % Validate modes
            typeModes = string(obj.validOptions.pfir.modes);
            toks = obj.modeTokens;
            if ~all(ismember(toks, typeModes))
                bad = toks(~ismember(toks, typeModes));
                error("Invalid PFIR mode token(s): %s. Allowed: %s", strjoin(bad,", "), strjoin(typeModes,", "));
            end

            % Gains
            typeGains = string(obj.validOptions.pfir.gain);
            obj.assertListMembership(obj.params.gain, typeGains, "Gain", "pfir");

            % Scalar gains
            typeScalarGains = string(obj.validOptions.pfir.scalar_gain);
            obj.assertListMembership(obj.params.scalar_gain, typeScalarGains, "Scalar Gain", "pfir");

            % hc_delay
            if ~ismember(string(obj.params.hc_delay), string(obj.validOptions.pfir.hc_delay))
                error("Invalid hc_delay '%s' for PFIR.", string(obj.params.hc_delay));
            end

            % Flags: accept 0/1 (numeric or string)
            flags = ["mode_switch_en","mode_switch_add_en","real_data_mode_en","quad_mode_en"];
            for f = flags
                v = obj.params.(f);
                if ~(isscalar(v) && (islogical(v) || (isnumeric(v) && (v==0 || v==1)) || ...
                     ((ischar(v) || isstring(v)) && any(string(v)==["0","1"]))))
                    error("Invalid value for %s. Use 0 or 1.", f);
                end
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

        function s = normalizeList(~, val, repeatCount)
            % Returns a single space-separated string.
            % If repeatCount is provided and val is scalar, replicate to that length.
            if nargin < 3, repeatCount = []; end

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

            % Replicate scalar if needed
            if ~isempty(repeatCount) && numel(list) == 1
                rep = str2double(string(repeatCount));
                if isnan(rep) || rep < 1
                    rep = 2; % safe fallback
                end
                list = repmat(list, 1, rep);
            end

            s = strjoin(list, " ");
        end

        function tokens = tokenizeModes(~, mode)
            if isstring(mode) || ischar(mode)
                tokens = split(strtrim(string(mode)));
                tokens = tokens(tokens ~= "");
                tokens = lower(tokens);
            elseif isstring(mode) && numel(mode) > 1
                tokens = lower(mode);
            elseif iscellstr(mode)
                tokens = lower(string(mode));
            else
                tokens = string.empty(1,0);
            end
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

% Must Be Text
function mustBeText(x)
if ~(ischar(x) || (isstring(x) && isscalar(x)))
    eid = 'PFIR:mustBeText';
    msg = 'Value must be a text scalar (char or 1x1 string).';
    throwAsCaller(MException(eid,msg));
end
end