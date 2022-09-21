proc preprocess_bd {project carrier rxtx} {

    puts "Preprocessing $project $carrier $rxtx"

    switch $project {
        daq2 {
            if {$rxtx == "rx" || $rxtx == "rxtx"} {
                # Disconnect the ADC PACK pins
                disconnect_bd_net /axi_ad9680_tpl_adc_valid_0 [get_bd_pins axi_ad9680_cpack/fifo_wr_en]
            
                disconnect_bd_net /axi_ad9680_tpl_adc_data_0 [get_bd_pins axi_ad9680_cpack/fifo_wr_data_0]
                disconnect_bd_net /axi_ad9680_tpl_adc_data_1 [get_bd_pins axi_ad9680_cpack/fifo_wr_data_1]
            
                # Connect the ADC PACK valid signals together
                # connect_bd_net [get_bd_pins axi_ad9680_cpack/adc_valid_0] [get_bd_pins axi_ad9680_cpack/adc_valid_1]
            }
            if {$rxtx == "tx" || $rxtx == "rxtx"} {
                # Disconnect the DAC PACK pins
                # VALID PINS NOT CONNECTED TO INTERFACE CORE ON DAC SIDE
            
                # DATA PINS
                delete_bd_objs [get_bd_nets dac_data_0_1]
                delete_bd_objs [get_bd_nets dac_data_1_1]
            }
            if {$rxtx == "rxtx"} {
                # Connect TX clocking to RX path
            
                # Reset reconnect
                disconnect_bd_net /util_daq2_xcvr_tx_out_clk_0 [get_bd_pins axi_ad9144_jesd_rstgen/slowest_sync_clk]
                connect_bd_net [get_bd_pins axi_ad9144_jesd_rstgen/slowest_sync_clk] [get_bd_pins util_daq2_xcvr/rx_out_clk_0]
            
                # axi_ad9144_tpl tx_clk reconnect
                disconnect_bd_net /util_daq2_xcvr_tx_out_clk_0 [get_bd_pins axi_ad9144_tpl/link_clk]
                connect_bd_net [get_bd_pins axi_ad9144_tpl/link_clk] [get_bd_pins util_daq2_xcvr/rx_out_clk_0]
            
                # upack dac_clk reconnect
                disconnect_bd_net /util_daq2_xcvr_tx_out_clk_0 [get_bd_pins axi_ad9144_upack/clk]
                connect_bd_net [get_bd_pins axi_ad9144_upack/clk] [get_bd_pins util_daq2_xcvr/rx_out_clk_0]
                
                # TX FIFO
                disconnect_bd_net /util_daq2_xcvr_tx_out_clk_0 [get_bd_pins axi_ad9144_fifo/dac_clk]
                connect_bd_net [get_bd_pins axi_ad9144_fifo/dac_clk] [get_bd_pins util_daq2_xcvr/rx_out_clk_0]
            
                # TX JESD
                disconnect_bd_net /util_daq2_xcvr_tx_out_clk_0 [get_bd_pins axi_ad9144_jesd/device_clk]
                connect_bd_net [get_bd_pins axi_ad9144_jesd/device_clk] [get_bd_pins util_daq2_xcvr/rx_out_clk_0]
            }
            switch $carrier {                
                zcu102 {                    
                    if {$rxtx == "rx" || $rxtx == "rxtx"} {
                        set_property -dict [list CONFIG.NUM_MI {10}] [get_bd_cells axi_cpu_interconnect]
                        connect_bd_net [get_bd_pins axi_cpu_interconnect/M09_ACLK] [get_bd_pins util_daq2_xcvr/rx_out_clk_0]
                    }
                    if {$rxtx == "tx"} {
                        set_property -dict [list CONFIG.NUM_MI {10}] [get_bd_cells axi_cpu_interconnect]
                        connect_bd_net [get_bd_pins axi_cpu_interconnect/M09_ACLK] [get_bd_pins util_daq2_xcvr/tx_out_clk_0]
                    }
                }
            }
        }
        ad9081_fmca_ebz {
            if {$rxtx == "rx" || $rxtx == "rxtx"} {
                # Disconnect the ADC PACK pins
                disconnect_bd_net /rx_mxfe_tpl_core_adc_valid_0 [get_bd_pins util_mxfe_cpack/fifo_wr_en]

                disconnect_bd_net /rx_mxfe_tpl_core_adc_data_0 [get_bd_pins util_mxfe_cpack/fifo_wr_data_0]
                disconnect_bd_net /rx_mxfe_tpl_core_adc_data_1 [get_bd_pins util_mxfe_cpack/fifo_wr_data_1]
                disconnect_bd_net /rx_mxfe_tpl_core_adc_data_2 [get_bd_pins util_mxfe_cpack/fifo_wr_data_2]
                disconnect_bd_net /rx_mxfe_tpl_core_adc_data_3 [get_bd_pins util_mxfe_cpack/fifo_wr_data_3]
                disconnect_bd_net /rx_mxfe_tpl_core_adc_data_4 [get_bd_pins util_mxfe_cpack/fifo_wr_data_4]
                disconnect_bd_net /rx_mxfe_tpl_core_adc_data_5 [get_bd_pins util_mxfe_cpack/fifo_wr_data_5]
                disconnect_bd_net /rx_mxfe_tpl_core_adc_data_6 [get_bd_pins util_mxfe_cpack/fifo_wr_data_6]
                disconnect_bd_net /rx_mxfe_tpl_core_adc_data_7 [get_bd_pins util_mxfe_cpack/fifo_wr_data_7]

                # Connect the ADC PACK valid signals together
                # connect_bd_net [get_bd_pins axi_ad9680_cpack/adc_valid_0] [get_bd_pins axi_ad9680_cpack/adc_valid_1]
            }
            if {$rxtx == "tx" || $rxtx == "rxtx"} {
                # Disconnect the DAC PACK pins
                # VALID PINS NOT CONNECTED TO INTERFACE CORE ON DAC SIDE

                # DATA PINS
                delete_bd_objs [get_bd_nets util_mxfe_upack_fifo_rd_data_0]
                delete_bd_objs [get_bd_nets util_mxfe_upack_fifo_rd_data_1]
                delete_bd_objs [get_bd_nets util_mxfe_upack_fifo_rd_data_2]
                delete_bd_objs [get_bd_nets util_mxfe_upack_fifo_rd_data_3]
                delete_bd_objs [get_bd_nets util_mxfe_upack_fifo_rd_data_4]
                delete_bd_objs [get_bd_nets util_mxfe_upack_fifo_rd_data_5]
                delete_bd_objs [get_bd_nets util_mxfe_upack_fifo_rd_data_6]
                delete_bd_objs [get_bd_nets util_mxfe_upack_fifo_rd_data_7]
            }
            if {$rxtx == "rxtx"} {
                # Connect TX clocking to RX path

                # Reset reconnect
                delete_bd_objs [get_bd_nets tx_device_clk_1]
                connect_bd_net [get_bd_pins tx_device_clk_rstgen/slowest_sync_clk] [get_bd_pins util_mxfe_xcvr/rx_out_clk_0]

                # UPACK reconnect
                connect_bd_net [get_bd_pins util_mxfe_upack/clk] [get_bd_pins util_mxfe_xcvr/rx_out_clk_0]

                # DAC FIFO reconnect
                connect_bd_net [get_bd_pins mxfe_tx_data_offload/m_axis_aclk] [get_bd_pins util_mxfe_xcvr/rx_out_clk_0]

                # TX TPL Core
                connect_bd_net [get_bd_pins tx_mxfe_tpl_core/link_clk] [get_bd_pins util_mxfe_xcvr/rx_out_clk_0]

                # TX JESD
                connect_bd_net [get_bd_pins axi_mxfe_tx_jesd/device_clk] [get_bd_pins util_mxfe_xcvr/rx_out_clk_0]

                connect_bd_net [get_bd_ports rx_device_clk] [get_bd_pins util_mxfe_xcvr/tx_clk_0]
                connect_bd_net [get_bd_ports rx_device_clk] [get_bd_pins util_mxfe_xcvr/tx_clk_1]
                connect_bd_net [get_bd_ports rx_device_clk] [get_bd_pins util_mxfe_xcvr/tx_clk_2]
                connect_bd_net [get_bd_ports rx_device_clk] [get_bd_pins util_mxfe_xcvr/tx_clk_3]
            }
            switch $carrier {                
                zcu102 {                    
                    if {$rxtx == "rx" || $rxtx == "rxtx"} {
                        set_property -dict [list CONFIG.NUM_MI {12}] [get_bd_cells axi_cpu_interconnect]
                        connect_bd_net [get_bd_pins axi_cpu_interconnect/M11_ACLK] [get_bd_pins util_mxfe_xcvr/rx_out_clk_0]
                    }
                    if {$rxtx == "tx"} {
                        set_property -dict [list CONFIG.NUM_MI {12}] [get_bd_cells axi_cpu_interconnect]
                        connect_bd_net [get_bd_pins axi_cpu_interconnect/M11_ACLK] [get_bd_pins util_mxfe_xcvr/tx_out_clk_0]
                    }
                }
            }
        }        
    }
}
