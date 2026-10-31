function writeDisabledFilter(filename, filter_type)
% writeDisabledFilter  Write a filter config file that bypasses/disables a filter.
%
%   writeDisabledFilter(filename, filter_type)
%
%   filename     : path to the output .txt file
%   filter_type  : 'pfir' — writes mode:disabled disabled (PFIR bypass)
%                  'cfir' — writes bypass:1 with identity coefficients (CFIR bypass)
%
%   PFIR: The AD9084 driver skips coefficient loading entirely when both
%         I and Q FIR modes are set to 'disabled'. Used as a 0 dB reference.
%
%   CFIR: Sets bypass:1 so the CFIR block is passed through unfiltered.
%
%   Example:
%       writeDisabledFilter('pfir_off.txt', 'pfir')
%       writeDisabledFilter('cfir_off.txt', 'cfir')

    if nargin < 2, filter_type = 'pfir'; end

    if strcmpi(filter_type, 'pfir')
        lines = {
            'mode: disabled disabled'
            'gain: 0 0 0 0'
            'scalar_gain: 0 0 0 0'
            'dest: rx pfilt_all bank_0'
            'hc_delay: 0'
            'mode_switch_en: 0'
            'mode_switch_add_en: 0'
            'real_data_mode_en: 1'
            'quad_mode_en: 0'
        };
    elseif strcmpi(filter_type, 'cfir')
        % bypass:1 instructs the driver to route data around the CFIR block.
        % Coefficients are included but irrelevant when bypass is active.
        zeroTap  = '0x0000';
        unityTap = '0x4000';  % Q14 unity for centre tap
        nTaps    = 16;
        midTap   = ceil(nTaps / 2);
        coeffLines = cell(nTaps, 1);
        for k = 1:nTaps
            if k == midTap
                coeffLines{k} = sprintf('%s %s', unityTap, unityTap);
            else
                coeffLines{k} = sprintf('%s %s', zeroTap, zeroTap);
            end
        end
        lines = [
            {'dest: rx cfir_all profile_2 datapath_all'}
            {'gain: 0'}
            {'complex_scalar: 32767 0'}
            {'enable: 1 profile_2'}
            {'selection_mode: direct_regmap'}
            {'coeff_transfer: 0'}
            {'bypass: 0'}
            {'sparse_mode: 0'}
            coeffLines
        ];
    else
        error('writeDisabledFilter: unknown filter_type "%s". Use ''pfir'' or ''cfir''.', filter_type);
    end

    fid = fopen(filename, 'w');
    if fid < 0
        error('writeDisabledFilter: cannot write file: %s', filename);
    end
    for k = 1:numel(lines)
        fprintf(fid, '%s\n', lines{k});
    end
    fclose(fid);
end
