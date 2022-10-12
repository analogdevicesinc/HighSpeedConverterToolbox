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
                disconnect_bd_net /util_daq2_xcvr_tx_out_clk_0 [get_bd_pins axi_ad9144_offload/m_axis_aclk]
                connect_bd_net [get_bd_pins axi_ad9144_offload/m_axis_aclk] [get_bd_pins util_daq2_xcvr/rx_out_clk_0]

                # TX JESD
                disconnect_bd_net /util_daq2_xcvr_tx_out_clk_0 [get_bd_pins axi_ad9144_jesd/device_clk]
                connect_bd_net [get_bd_pins axi_ad9144_jesd/device_clk] [get_bd_pins util_daq2_xcvr/rx_out_clk_0]
            }
            switch $carrier {
                zcu102 {
    		    set_property -dict [list CONFIG.NUM_CLKS {2}] [get_bd_cells axi_cpu_interconnect]
                    if {$rxtx == "rx" || $rxtx == "rxtx"} {
                        set_property -dict [list CONFIG.NUM_MI {12}] [get_bd_cells axi_cpu_interconnect]
                        connect_bd_net [get_bd_pins axi_cpu_interconnect/aclk1] [get_bd_pins util_daq2_xcvr/rx_out_clk_0]
                    }
                    if {$rxtx == "tx"} {
                        set_property -dict [list CONFIG.NUM_MI {12}] [get_bd_cells axi_cpu_interconnect]
                        connect_bd_net [get_bd_pins axi_cpu_interconnect/aclk1] [get_bd_pins util_daq2_xcvr/tx_out_clk_0]
                    }
                }
            }
        }
        ad9434_fmc {
            if {$rxtx == "rx"} {
                #Disconnect valid pins
                delete_bd_objs [get_bd_nets axi_ad9434_adc_valid]
                
                # Disconnect the ADC pins
                delete_bd_objs [get_bd_nets axi_ad9434_adc_data]

                set i 3
                while {$i >= 0} {
                    create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 xlslice_$i
                    set_property -dict [list CONFIG.DIN_TO [expr $i * 12] CONFIG.DIN_FROM [expr ($i +1) * 12 -1] CONFIG.DIN_WIDTH {64} CONFIG.DOUT_WIDTH {12}] [get_bd_cells xlslice_$i]
                    # Connect the axi_ad9434 out to the slice blocks
                    connect_bd_net [get_bd_pins xlslice_${i}/Din] [get_bd_pins axi_ad9434/adc_data]

                    set i [expr $i - 1]
                }
                #create an extra slice for the leftover bits 
                create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 xlslice_4
                
                set_property -dict [list CONFIG.DIN_TO {48} CONFIG.DIN_FROM {63} CONFIG.DIN_WIDTH {64} CONFIG.DOUT_WIDTH {16}] [get_bd_cells xlslice_4]

                connect_bd_net [get_bd_pins axi_ad9434/adc_data] [get_bd_pins xlslice_4/Din]
                

                #Create Concat block
                create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat:2.1 xlconcat_0
                set_property -dict [list CONFIG.NUM_PORTS {5}] [get_bd_cells xlconcat_0]


                set j 3
                while {$j >= 0 } {
                    set_property -dict [list CONFIG.IN${j}_WIDTH.VALUE_SRC USER] [get_bd_cells xlconcat_0]
                    set_property -dict [list CONFIG.IN${j}_WIDTH {12}] [get_bd_cells xlconcat_0]

                    set j [expr $j - 1]
                }
                set_property -dict [list CONFIG.IN4_WIDTH.VALUE_SRC USER] [get_bd_cells xlconcat_0]
                set_property -dict [list CONFIG.IN4_WIDTH {16}] [get_bd_cells xlconcat_0]

                # connect the concat block to the axi_ad9434_dma
                connect_bd_net [get_bd_pins axi_ad9434_dma/fifo_wr_din] [get_bd_pins xlconcat_0/dout]
            }
            switch $carrier {                
                zc706 {                    
                    if {$rxtx == "rx"} {
                        set_property -dict [list CONFIG.NUM_MI {9}] [get_bd_cells axi_cpu_interconnect]
                        connect_bd_net [get_bd_pins axi_cpu_interconnect/M08_ACLK] [get_bd_pins axi_ad9434/adc_clk]
                        connect_bd_net [get_bd_pins sys_rstgen/peripheral_aresetn] [get_bd_pins axi_cpu_interconnect/M08_ARESETN]
                    }
                }
            }
        }
        ad9739a_fmc {
         
            if {$rxtx == "tx"} {
                # Disconnect the DAC PACK pins
                # VALID PINS NOT CONNECTED TO INTERFACE CORE ON DAC SIDE
                delete_bd_objs [get_bd_nets axi_ad9739a_dma_fifo_rd_dout]

                # Create Slice blocks 
                set i 15
                while {$i >= 0} {
                    create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 xlslice_$i
                    set_property -dict [list CONFIG.DIN_TO [expr $i * 16] CONFIG.DIN_FROM [expr ($i +1) * 16 -1] CONFIG.DIN_WIDTH {256} CONFIG.DOUT_WIDTH {16}] [get_bd_cells xlslice_$i]
                    # Connect the fifo out to the slice blocks
                    connect_bd_net [get_bd_pins xlslice_${i}/Din] [get_bd_pins axi_ad9739a_dma/fifo_rd_dout]
                   
                    set i [expr $i - 1]
                }

                #Create Concat block
                create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat:2.1 xlconcat_0
                set_property -dict [list CONFIG.NUM_PORTS {16}] [get_bd_cells xlconcat_0]

                set j 15
                while {$j >= 0 } {
                    set_property -dict [list CONFIG.IN${j}_WIDTH.VALUE_SRC USER] [get_bd_cells xlconcat_0]
                    set_property -dict [list CONFIG.IN${j}_WIDTH {16}] [get_bd_cells xlconcat_0]

                    set j [expr $j - 1]
                }
                # connect the concat block to the axi_ad9739a
                connect_bd_net [get_bd_pins xlconcat_0/dout] [get_bd_pins axi_ad9739a/dac_ddata]
                
            }
            switch $carrier {                
                zc706 {                    
                    if {$rxtx == "tx"} {
                        set_property -dict [list CONFIG.NUM_MI {9}] [get_bd_cells axi_cpu_interconnect]
                        connect_bd_net [get_bd_pins axi_cpu_interconnect/M08_ACLK] [get_bd_pins sys_ps7/FCLK_CLK0]
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

		        disconnect_bd_net /util_mxfe_xcvr_tx_out_clk_0 [get_bd_pins axi_mxfe_tx_jesd/link_clk]
		        connect_bd_net [get_bd_ports rx_device_clk] [get_bd_pins axi_mxfe_tx_jesd/link_clk]
        
		        disconnect_bd_net /util_mxfe_xcvr_tx_out_clk_0 [get_bd_pins util_mxfe_xcvr/tx_clk_0]
		        disconnect_bd_net /util_mxfe_xcvr_tx_out_clk_0 [get_bd_pins util_mxfe_xcvr/tx_clk_1]
		        disconnect_bd_net /util_mxfe_xcvr_tx_out_clk_0 [get_bd_pins util_mxfe_xcvr/tx_clk_2]
		        disconnect_bd_net /util_mxfe_xcvr_tx_out_clk_0 [get_bd_pins util_mxfe_xcvr/tx_clk_3]

                connect_bd_net [get_bd_ports rx_device_clk] [get_bd_pins util_mxfe_xcvr/tx_clk_0]
                connect_bd_net [get_bd_ports rx_device_clk] [get_bd_pins util_mxfe_xcvr/tx_clk_1]
                connect_bd_net [get_bd_ports rx_device_clk] [get_bd_pins util_mxfe_xcvr/tx_clk_2]
                connect_bd_net [get_bd_ports rx_device_clk] [get_bd_pins util_mxfe_xcvr/tx_clk_3]
            }
            switch $carrier {
                zcu102 {
                    set_property -dict [list CONFIG.NUM_CLKS {2}] [get_bd_cells axi_cpu_interconnect]
	            if {$rxtx == "rx" || $rxtx == "rxtx"} {
                        set_property -dict [list CONFIG.NUM_MI {12}] [get_bd_cells axi_cpu_interconnect]
                        connect_bd_net [get_bd_pins axi_cpu_interconnect/aclk1] [get_bd_pins util_mxfe_xcvr/rx_out_clk_0]
                    }
                    if {$rxtx == "tx"} {
                        set_property -dict [list CONFIG.NUM_MI {12}] [get_bd_cells axi_cpu_interconnect]
                        connect_bd_net [get_bd_pins axi_cpu_interconnect/aclk1] [get_bd_pins util_mxfe_xcvr/tx_out_clk_0]
                    }
                }
            }
        }
        ad9265_fmc {
            if {$rxtx == "rx"} {
                # Disconnect the ADC pins
                disconnect_bd_net /axi_ad9265_adc_valid [get_bd_pins axi_ad9265_dma/fifo_wr_en]
                disconnect_bd_net /axi_ad9265_adc_data [get_bd_pins axi_ad9265_dma/fifo_wr_din]

             }
 
            switch $carrier {
                zc706 {
    		    if {$rxtx == "rx" } {
                        set_property -dict [list CONFIG.NUM_MI {9}] [get_bd_cells axi_cpu_interconnect]
                        connect_bd_net [get_bd_pins axi_cpu_interconnect/M08_ACLK] [get_bd_pins axi_ad9265/adc_clk]
                    }
                }
            }
        } 
        
        fmcjesdadc1 {
            if {$rxtx == "rx" } {
                # Disconnect the ADC PACK pins
                disconnect_bd_net /axi_ad9250_core_adc_valid_0 [get_bd_pins axi_ad9250_cpack/fifo_wr_en]
               

                disconnect_bd_net /axi_ad9250_core_adc_data_0 [get_bd_pins axi_ad9250_cpack/fifo_wr_data_0]
                disconnect_bd_net /axi_ad9250_core_adc_data_1 [get_bd_pins axi_ad9250_cpack/fifo_wr_data_1]
                disconnect_bd_net /axi_ad9250_core_adc_data_2 [get_bd_pins axi_ad9250_cpack/fifo_wr_data_2]
                disconnect_bd_net /axi_ad9250_core_adc_data_3 [get_bd_pins axi_ad9250_cpack/fifo_wr_data_3]
               

                # Connect the ADC PACK valid signals together
                 
            }
            switch $carrier {                
                zc706 {                    
                    if {$rxtx == "rx" } {
                        set_property -dict [list CONFIG.NUM_MI {11}] [get_bd_cells axi_cpu_interconnect]
                        connect_bd_net [get_bd_pins axi_cpu_interconnect/M10_ACLK] [get_bd_pins util_fmcjesdadc1_xcvr/rx_clk_0]
                    }
                }
            }
        } 
    }
}

