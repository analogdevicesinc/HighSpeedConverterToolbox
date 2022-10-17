function add_clocks(hRD,project,design)

switch lower(project)
    case 'daq2'
        switch(upper(design))
            case 'RX'
                hRD.addClockInterface( ...
                    'ClockConnection',   'util_daq2_xcvr/rx_out_clk_0', ...
                    'ResetConnection',   'axi_ad9680_jesd_rstgen/peripheral_aresetn');
            case 'TX'
                hRD.addClockInterface( ...
                    'ClockConnection',   'util_daq2_xcvr/tx_out_clk_0', ...
                    'ResetConnection',   'axi_ad9144_jesd_rstgen/peripheral_aresetn');
            case 'RX & TX'
                hRD.addClockInterface( ...
                    'ClockConnection',   'util_daq2_xcvr/rx_out_clk_0', ...
                    'ResetConnection',   'axi_ad9680_jesd_rstgen/peripheral_aresetn');
            otherwise
                error('Unknown reference design');
        end    
    case 'ad9081'
        switch(upper(design))
            case 'RX'
                hRD.addClockInterface( ...
                    'ClockConnection',   'util_mxfe_xcvr/rx_out_clk_0', ...
                    'ResetConnection',   'rx_device_clk_rstgen/peripheral_aresetn');
            case 'TX'
                hRD.addClockInterface( ...
                    'ClockConnection',   'util_mxfe_xcvr/tx_out_clk_0', ...
                    'ResetConnection',   'tx_device_clk_rstgen/peripheral_aresetn');
            case 'RX & TX'
                hRD.addClockInterface( ...
                    'ClockConnection',   'util_mxfe_xcvr/rx_out_clk_0', ...
                    'ResetConnection',   'rx_device_clk_rstgen/peripheral_aresetn');
            otherwise
                error('Unknown reference design');
        end  
    case 'ad9208'
        switch(upper(design))
            case 'RX'
                hRD.addClockInterface( ...
                    'ClockConnection',   'glbl_clk_0', ...
                    'ResetConnection',   'sys_rstgen/peripheral_aresetn');
            otherwise
                error('Unknown reference design');
        end 
end
