function ref_name = get_ref_name(rd_name)

    s = strsplit(rd_name, ' ');
    board = lower(s{1});
    carrier = lower(s{2});
    % "(RX & TX)" spans several tokens; keep it distinct from "(RX)".
    variant = lower(strjoin(s(3:end), ''));
    variant = regexprep(variant, '[()&]', '');

    fprintf('Board: %s | Carrier %s \n', board, carrier);

    % Boards without a hardware test mapping keep a carrier-board name so
    % a completed build still archives its BOOT.BIN.
    ref_name = sprintf('%s-%s', carrier, board);

    switch carrier
        case 'zcu102'
            switch lower(board)
                case 'daq2'
                    ref_name = 'zynqmp-zcu102-rev10-fmcdaq2';
                case 'ad9081'
                    ref_name = 'zynqmp-zcu102-rev10-ad9081-m8_l4';
            end
    end

    ref_name = sprintf('%s_%s_BOOT.BIN', ref_name, variant);

end