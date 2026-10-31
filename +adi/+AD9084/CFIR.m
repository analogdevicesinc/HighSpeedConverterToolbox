classdef CFIR
    % AD9084CFIR
    %   - Encapsulates CFIR-specific catalogs, defaults, validation, and file output.
    %   - Constructor accepts taps and (optional) params as Name-Value pairs.
    %   - Always outputs HEX coefficients by calling FIRcoeff
    %   - Header lines follow CFIR format, e.g.:
    %       dest: rx cfir_all profile_2 datapath_all
    %       gain: 0
    %       complex_scalar: 32767 0
    %       enable: 1 profile_2
    %       selection_mode: direct_regmap
    %       coeff_transfer: 0
    %       bypass: 0

    properties
        taps (:,1) double

        %profile Profile Number
        %   Profile index for the CFIR block. Used to auto-build
        %   'dest' and 'enable' header tokens (e.g., 'profile_2').
        profile (1,1) double = 2

        %gain Shift Gain (dB)
        %   Programmable gain block at the CFIR output. Ranges from
        %   -18 dB to +12 dB in 6 dB steps.
        gain (1,1) string {mustBeMember(gain, ["-18","-12","-6","0","6","12"])} = "0"

        %complex_scalar Complex Scalar Multiplier
        %   Complex scalar applied after filtering. Normalized by 32767.
        %   32767+0i = unity real, 0+32767i = 90 degree rotation.
        %   Real and imaginary parts must be integers in [-32768, 32767].
        complex_scalar (1,1) double = 32767+0i

        %dest Destination
        %   Header destination string for the filter file.
        %   If empty, auto-built from profile (e.g., 'rx cfir_all profile_2 datapath_all').
        dest (1,1) string = ""

        %enable Enable String
        %   Header enable string. If empty, auto-built from profile
        %   (e.g., '1 profile_2').
        enable (1,1) string = ""

        %selection_mode Profile Selection Mode
        %   Controls how CFIR profiles are switched.
        %   Options: 'direct_regmap', 'direct_gpio', 'trig_regmap',
        %            'trig_gpio', 'trig_auto'
        selection_mode (1,1) string {mustBeMember(selection_mode, ["direct_regmap","direct_gpio","trig_regmap","trig_gpio","trig_auto"])} = "direct_regmap"

        %coeff_transfer Coefficient Transfer
        %   Trigger coefficient transfer to hardware. '0' or '1'.
        coeff_transfer (1,1) string {mustBeMember(coeff_transfer, ["0","1"])} = "0"

        %bypass Bypass
        %   Bypass the CFIR filter block. '0' = filter active, '1' = bypassed.
        bypass (1,1) string {mustBeMember(bypass, ["0","1"])} = "0"

        %sparse_mode Sparse Mode
        %   Enable 128-tap sparse CFIR (16 non-zero taps selectable
        %   anywhere in the impulse response).
        %   0 = normal mode (max 16 taps), 1 = sparse mode (max 128 taps).
        sparse_mode (1,1) double {mustBeMember(sparse_mode, [0 1])} = 0
    end

    methods
        function obj = CFIR(taps, options)
            arguments
                taps (:,1) double

                options.profile          (1,1) double   = 2
                options.gain             (1,1) string {mustBeMember(options.gain, ["-18","-12","-6","0","6","12"])} = "0"
                options.complex_scalar   (1,1) double   = 32767+0i
                options.dest             (1,1) string   = ""
                options.enable           (1,1) string   = ""
                options.selection_mode   (1,1) string {mustBeMember(options.selection_mode, ["direct_regmap","direct_gpio","trig_regmap","trig_gpio","trig_auto"])} = "direct_regmap"
                options.coeff_transfer   (1,1) string {mustBeMember(options.coeff_transfer, ["0","1"])} = "0"
                options.bypass           (1,1) string {mustBeMember(options.bypass, ["0","1"])} = "0"
                options.sparse_mode      (1,1) double {mustBeMember(options.sparse_mode,[0 1])} = 0
            end

            obj.taps = taps(:);

            % Validate tap count
            isSparse = (options.sparse_mode == 1);
            maxTaps = 128 * isSparse + 16 * ~isSparse;
            if numel(obj.taps) > maxTaps
                modeLabels = ["normal","sparse"];
                error('CFIR: %d taps provided but max is %d (%s mode).', ...
                      numel(obj.taps), maxTaps, modeLabels(isSparse + 1));
            end

            % Validate complex_scalar components
            cs_r = real(options.complex_scalar);
            cs_i = imag(options.complex_scalar);
            if any([cs_r cs_i] < -32768) || any([cs_r cs_i] > 32767) || ...
               cs_r ~= floor(cs_r) || cs_i ~= floor(cs_i)
                error("CFIR: 'complex_scalar' real and imag parts must be integers in [-32768, 32767]. Got %g%+gi.", cs_r, cs_i);
            end

            % Assign properties
            obj.profile          = options.profile;
            obj.gain             = options.gain;
            obj.complex_scalar   = options.complex_scalar;
            obj.dest             = options.dest;
            obj.enable           = options.enable;
            obj.selection_mode   = options.selection_mode;
            obj.coeff_transfer   = options.coeff_transfer;
            obj.bypass           = options.bypass;
            obj.sparse_mode      = options.sparse_mode;

            % Fill in profile-dependent header fields if empty
            obj = obj.finalizeHeaderTokens();
        end

        function outfile = write(obj, outfile)
            arguments
                obj
                outfile (1,1) string
            end

            [hexI, hexQ] = FIRcoeff(obj.taps);
            headerLines = obj.previewHeader();

            fid = fopen(outfile, 'w');
            if fid < 0, error('Cannot open file for writing: %s', outfile); end
            cleaner = onCleanup(@() fclose(fid));

            for i = 1:numel(headerLines)
                fprintf(fid, '%s\n', headerLines(i));
            end

            for i = 1:size(hexI, 1)
                fprintf(fid, '0x%s 0x%s\n', hexI(i,:), hexQ(i,:));
            end
        end

        function lines = previewHeader(obj)
            lines = [
                "dest: "            + obj.dest
                "gain: "            + obj.gain
                "complex_scalar: "  + sprintf('%g %g', real(obj.complex_scalar), imag(obj.complex_scalar))
                "enable: "          + obj.enable
                "selection_mode: "  + obj.selection_mode
                "coeff_transfer: "  + obj.coeff_transfer
                "bypass: "          + obj.bypass
                "sparse_mode: "     + string(obj.sparse_mode)
            ];
        end

        function [H, f] = response(obj, Fs, options)
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

            cs = obj.complex_scalar / 32767;

            H = H_fir * cs * 10^(shift_gain_dB/20);
            f = f_vec;

            if nargout == 0
                H_dBFS = 20*log10(abs(H) / max(abs(H)) + eps);
                figure('Name', 'CFIR Hardware Response');
                plot(f/1e6, H_dBFS, 'b-', 'LineWidth', 1.2);
                hold on; grid on;
                xlabel('Frequency (MHz)'); ylabel('Magnitude (dBFS)');
                title(sprintf('CFIR Response (gain=%s dB, scalar=%g%+gi)', ...
                    obj.gain, real(obj.complex_scalar), imag(obj.complex_scalar)));
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

        function obj = finalizeHeaderTokens(obj)
            profTok = sprintf('profile_%d', obj.profile);

            if strlength(obj.dest) == 0
                obj.dest = "rx cfir_all " + profTok + " datapath_all";
            end
            if strlength(obj.enable) == 0
                obj.enable = "1 " + profTok;
            end
        end
    end
end
