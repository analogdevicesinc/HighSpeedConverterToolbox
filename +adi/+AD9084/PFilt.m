classdef PFilt
    % AD9084PFIR
    %   - Encapsulates PFIR-specific catalogs, defaults, validation, and file output.
    %   - Constructor accepts taps and Name-Value pairs (editor will suggest names).
    %   - Infers PFIR mode(s) from taps length if 'mode' is empty.
    %   - Always outputs HEX coefficients by calling FIRcoeff

    properties
        taps (:,1) double

        %mode PFIR Filter Mode
        %   Determines the PFIR operating mode and max taps per path.
        %   Options: 'matrix', 'half_complex', 'real_n2', 'real_n4', 'disabled'
        %   If empty, mode is inferred from tap length.
        mode (1,1) string = ""

        %gain Shift Gain (dB)
        %   Programmable gain block at the PFIR output. Ranges from
        %   0 dB to 24 dB in 6 dB steps. Applied after FIR filtering.
        gain (1,1) string {mustBeMember(gain, ["0","6","12","18","24"])} = "0"

        %scalar_gain Scalar Gain
        %   6-bit unsigned integer (0 to 63). Represents a fractional
        %   multiplier of N/64. 0 = silence, 63 = unity. Max scalar
        %   gain (63) and max shift gain (24 dB) cannot be used together.
        scalar_gain (1,1) string = "0"

        %dest Destination
        %   Header destination string for the filter file.
        %   If empty, auto-built as 'rx pfilt_all bank_0'.
        dest (1,1) string = ""

        %hc_delay Half-Complex Delay
        %   Delay setting for half-complex mode. Options: '0','1','2','3'
        hc_delay (1,1) string {mustBeMember(hc_delay, ["0","1","2","3"])} = "0"

        %mode_switch_en Mode Switch Enable
        %   Enable dynamic mode switching between PFIR profiles. 0 or 1.
        mode_switch_en (1,1) double {mustBeMember(mode_switch_en, [0 1])} = 0

        %mode_switch_add_en Mode Switch Add Enable
        %   Enable additive mode switching. 0 or 1.
        mode_switch_add_en (1,1) double {mustBeMember(mode_switch_add_en, [0 1])} = 0

        %real_data_mode_en Real Data Mode Enable
        %   When 1, PFIR operates on real data. When 0, complex data. Default 1.
        real_data_mode_en (1,1) double {mustBeMember(real_data_mode_en, [0 1])} = 1

        %quad_mode_en Quadrature Mode Enable
        %   Enable quadrature (I/Q correction) mode. 0 or 1.
        quad_mode_en (1,1) double {mustBeMember(quad_mode_en, [0 1])} = 0

        %repeatCount Repeat Count
        %   Number of times to replicate gain/scalar_gain values in the
        %   header when a scalar value is provided. Matches path count.
        repeatCount (1,1) double = 4

        %profile Profile Number
        %   Profile index used to auto-build the 'dest' header token.
        profile (1,1) double = 2

        modeTokens (1,2) string
    end

    properties (SetAccess=private)
        TapLength (1,1) double
    end

    properties (Access=private)
        validOptions struct
        modeDefaults struct
    end

    methods
        function obj = PFilt(taps, options)
            arguments
                taps (:,1) double

                options.mode               (1,1) string   = ""
                options.gain               (1,1) string {mustBeMember(options.gain, ["0","6","12","18","24"])} = "0"
                options.scalar_gain        (1,1) string   = "0"
                options.dest               (1,1) string   = ""
                options.hc_delay           (1,1) string {mustBeMember(options.hc_delay, ["0","1","2","3"])} = "0"
                options.mode_switch_en     (1,1) double   {mustBeMember(options.mode_switch_en, [0 1])} = 0
                options.mode_switch_add_en (1,1) double   {mustBeMember(options.mode_switch_add_en, [0 1])} = 0
                options.real_data_mode_en  (1,1) double   {mustBeMember(options.real_data_mode_en,[0 1])} = 1
                options.quad_mode_en       (1,1) double   {mustBeMember(options.quad_mode_en,   [0 1])} = 0
                options.repeatCount        (1,1) double   = 4
                options.profile            (1,1) double   = 2
            end

            obj.taps = taps(:);

            % Build catalogs (PFIR)
            [obj.validOptions, obj.modeDefaults] = obj.buildCatalogs();

            % Assign properties
            obj.mode               = options.mode;
            obj.gain               = options.gain;
            obj.scalar_gain        = options.scalar_gain;
            obj.dest               = options.dest;
            obj.hc_delay           = options.hc_delay;
            obj.mode_switch_en     = options.mode_switch_en;
            obj.mode_switch_add_en = options.mode_switch_add_en;
            obj.real_data_mode_en  = options.real_data_mode_en;
            obj.quad_mode_en       = options.quad_mode_en;
            obj.repeatCount        = options.repeatCount;
            obj.profile            = options.profile;

            % Fill in dest if empty
            obj = obj.finalizeHeaderTokens();

            % Infer / finalize mode tokens, ensure tap-length fit
            [obj.modeTokens, obj.mode, obj.TapLength] = ...
                obj.inferModesAndTapLength(obj.taps, obj.mode);

            % Validate scalar_gain range
            obj.validateScalarGain();
        end

        function outfile = write(obj, outfile)
            arguments
                obj
                outfile (1,1) string
            end

            [hexI, ~] = FIRcoeff(obj.taps);

            headerLines = obj.buildHeaderLines();

            fid = fopen(outfile, 'w');
            if fid < 0, error('Cannot open file for writing: %s', outfile); end
            cleaner = onCleanup(@() fclose(fid));

            for i = 1:numel(headerLines)
                fprintf(fid, '%s\n', headerLines(i));
            end

            for i = 1:size(hexI, 1)
                fprintf(fid, '0x%s\n', hexI(i,:));
            end
        end

        function lines = previewHeader(obj)
            lines = obj.buildHeaderLines();
        end

        function [H, f] = response(obj, Fs, options)
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

            taps_q = round(obj.taps * 2^15) / 2^15;

            f_vec = linspace(-Fs/2, Fs/2, options.N).';
            [H_fir, ~] = freqz(taps_q, 1, f_vec, Fs);

            if options.useLUT || options.lutFile ~= ""
                lut = obj.loadLUT(options.lutFile);
            else
                lut = struct();
            end

            if ~isempty(fieldnames(lut)) && isfield(lut, 'shift_gain_sweep')
                programmed_gain = str2double(obj.gain);
                shift_gain_dB = interp1( ...
                    lut.shift_gain_sweep.shift_gain_values_dB, ...
                    lut.shift_gain_sweep.gain_dB, ...
                    programmed_gain, 'linear', 'extrap');
            else
                shift_gain_dB = str2double(obj.gain);
            end

            if ~isempty(fieldnames(lut)) && isfield(lut, 'scalar_sweep')
                programmed_scalar = str2double(obj.scalar_gain);
                scalar_gain_dB = interp1( ...
                    lut.scalar_sweep.scalar_values, ...
                    lut.scalar_sweep.gain_dB, ...
                    programmed_scalar, 'linear', 'extrap');
            else
                programmed_scalar = str2double(obj.scalar_gain);
                scalar_gain_dB = 20*log10(programmed_scalar / 64 + eps);
            end

            total_gain_linear = 10^(shift_gain_dB/20) * 10^(scalar_gain_dB/20);
            H = H_fir * total_gain_linear;
            f = f_vec;

            if nargout == 0
                H_dBFS = 20*log10(abs(H) / max(abs(H)) + eps);
                figure('Name', 'PFilt Hardware Response');
                plot(f/1e9, H_dBFS, 'b-', 'LineWidth', 1.2);
                hold on; grid on;
                xlabel('Frequency (GHz)'); ylabel('Magnitude (dBFS)');
                title(sprintf('PFilt Response (gain=%s dB, scalar=%s)', ...
                    obj.gain, obj.scalar_gain));
                clear H f;
            end
        end
    end

    methods (Access=private)
        function lut = loadLUT(~, lutFile)
            if lutFile ~= ""
                [~, fname] = fileparts(lutFile);
                addpath(fileparts(lutFile));
                lut = feval(fname);
                return;
            end
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
            validOptions.pfir.modes              = {'matrix','half_complex','real_n2','real_n4','disabled'};
            validOptions.pfir.scalar_gain        = arrayfun(@num2str, 0:64, 'UniformOutput', false);

            modeDefaults.pfir.matrix       = struct('N',  16);
            modeDefaults.pfir.half_complex = struct('N', 16);
            modeDefaults.pfir.real_n2      = struct('N', 16);
            modeDefaults.pfir.real_n4      = struct('N', 32);
            modeDefaults.pfir.disabled     = struct('N', 16);
        end

        function obj = finalizeHeaderTokens(obj)
            if strlength(obj.dest) == 0
                obj.dest = "rx pfilt_all bank_0";
            end
        end

        function [modeTokens, modeStr, N_eff] = inferModesAndTapLength(obj, taps, modeStr)
            toks = obj.tokenizeModes(modeStr);

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
                modeStr = strjoin(toks," ");
            elseif numel(toks)==1
                toks = [toks, toks];
                modeStr = strjoin(toks," ");
            elseif numel(toks)~=2
                error("Provide zero, one, or two mode tokens (one per path). Got: %s", strjoin(toks," "));
            end

            % Validate mode tokens
            typeModes = string(obj.validOptions.pfir.modes);
            if ~all(ismember(toks, typeModes))
                bad = toks(~ismember(toks, typeModes));
                error("Invalid PFIR mode token(s): %s. Allowed: %s", strjoin(bad,", "), strjoin(typeModes,", "));
            end

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

        function validateScalarGain(obj)
            allowed = string(obj.validOptions.pfir.scalar_gain);
            toks = split(strtrim(obj.scalar_gain));
            toks = toks(toks ~= "");
            if ~all(ismember(toks, allowed))
                error("Invalid scalar_gain '%s'. Must be integer 0-64.", obj.scalar_gain);
            end
        end

        function lines = buildHeaderLines(obj)
            rep = obj.repeatCount;
            lines = [
                "mode: "               + obj.normalizeList(obj.mode, [])
                "gain: "               + obj.normalizeList(obj.gain, rep)
                "scalar_gain: "        + obj.normalizeList(obj.scalar_gain, rep)
                "dest: "               + obj.normalizeList(obj.dest, [])
                "hc_delay: "           + string(obj.hc_delay)
                "mode_switch_en: "     + string(obj.mode_switch_en)
                "mode_switch_add_en: " + string(obj.mode_switch_add_en)
                "real_data_mode_en: "  + string(obj.real_data_mode_en)
                "quad_mode_en: "       + string(obj.quad_mode_en)
            ];
        end

        function s = normalizeList(~, val, repeatCount)
            if nargin < 3, repeatCount = []; end

            txt = strtrim(string(val));
            if contains(txt, " ")
                s = txt;
                return;
            end
            list = txt;

            if ~isempty(repeatCount) && numel(list) == 1
                rep = double(repeatCount);
                if isnan(rep) || rep < 1
                    rep = 2;
                end
                list = repmat(list, 1, rep);
            end

            s = strjoin(list, " ");
        end

        function tokens = tokenizeModes(~, mode)
            tokens = split(strtrim(string(mode)));
            tokens = tokens(tokens ~= "");
            tokens = lower(tokens);
        end
    end
end
