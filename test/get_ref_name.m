function ref_name = get_ref_name(rd_name)

    s = strsplit(rd_name, ' ');
    board = lower(s{1});
    carrier = lower(s{2});
    variant = lower(s{3});
    variant = strrep(variant, '(', '');
    variant = strrep(variant, ')', '');

    fprintf('Board: %s | Carrier %s \n', board, carrier);

    ref_name = '';

    switch carrier
        case 'zcu102'
            switch lower(board)
                case 'daq2'
                    ref_name = 'zynqmp-zcu102-rev10-fmcdaq2';
                case 'ad9081'
                    ref_name = 'zynqmp-zcu102-rev10-ad9081-m8_l4';
            end
        
        otherwise
            error('Unknown Carrier');
    end
   

    if strcmpi(ref_name, '')
        error('Unknown board/carrier')
    end

    ref_name = sprintf('%s_%s_BOOT.BIN', ref_name, variant);

end