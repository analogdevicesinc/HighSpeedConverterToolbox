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
    case 'ad9434'
        switch(upper(design))
            case 'RX'
                hRD.addClockInterface( ...
                    'ClockConnection',   'axi_ad9434/adc_clk', ...
                    'ResetConnection',   'sys_rstgen/peripheral_aresetn');
            otherwise
                error('Unknown reference design');
        end
    case 'ad9739a'
        switch(upper(design))
            case 'TX'
                hRD.addClockInterface( ...
                    'ClockConnection',   'sys_ps7/FCLK_CLK0', ...
                    'ResetConnection',   'sys_rstgen/peripheral_aresetn');
            otherwise
                error('Unknown reference design');
        end
    case 'ad9265'
        switch(upper(design))
            case 'RX'
                hRD.addClockInterface( ...
                    'ClockConnection',   'axi_ad9265/adc_clk', ...
                    'ResetConnection',   'sys_rstgen/peripheral_aresetn');
            otherwise
                error('Unknown reference design');
        end
    case 'fmcjesdadc1'
        switch(upper(design))
            case 'RX'
                hRD.addClockInterface( ...
                    'ClockConnection',   'util_fmcjesdadc1_xcvr/rx_clk_0', ...
                    'ResetConnection',   'sys_rstgen/peripheral_aresetn');
            otherwise
                error('Unknown reference design');
        end
    case 'ad9783'
        switch(upper(design))
            case 'TX'
                hRD.addClockInterface( ...
                    'ClockConnection',   'axi_ad9783/dac_div_clk', ...
                    'ResetConnection',   'axi_ad9783/dac_rst');
            otherwise
                error('Unknown reference design');
        end
end
