# Recreate a plain BD input port as a clock port, keeping its connections.
# Smartconnect only inserts a clock converter for an interface whose clock
# carries its own CLK_DOMAIN; plain ports leave it on the interconnect clock.
proc make_clock_port {name freq_hz} {
    set net [get_bd_nets -of_objects [get_bd_ports $name]]
    set pins [get_bd_pins -of_objects $net]
    delete_bd_objs $net [get_bd_ports $name]
    create_bd_port -dir I -type clk -freq_hz $freq_hz $name
    foreach pin $pins {
        connect_bd_net [get_bd_ports $name] $pin
    }
}

# Write an implementation-only XDC next to the project being built and add it
# to the current project's constraints.
proc add_project_xdc {name contents} {
    set path [file normalize $name]
    set fd [open $path w]
    puts $fd $contents
    close $fd
    add_files -fileset constrs_1 -norecurse $path
    set_property USED_IN_SYNTHESIS false [get_files $path]
}

# Clock the HDL Coder DUT from a device clock pin that is not a clock
# interface (no CLK_DOMAIN), with its AXI4-Lite slave behind an asynchronous
# clock converter. Smartconnect cannot insert the crossing itself because the
# device pin has no clock domain, so it would time the DUT AXI4-Lite as
# synchronous to the CPU clock.
#   dut_clk/clk_out                 DUT IPCORE_CLK / AXI4_Lite_ACLK
#   dut_rstgen/peripheral_aresetn   DUT IPCORE_RESETN / AXI4_Lite_ARESETN
#   dut_axi_cdc/M_AXI               DUT AXI4_Lite
# dut_clk is a clk_vip in pass-through mode (a wire in synthesis). It gives the
# device clock a clock type and domain in the block design; it adds no logic
# and no in-context constraints.
proc add_dut_axi_lite_cdc {cpu_interconnect master_port device_clk} {
    create_bd_cell -type ip -vlnv xilinx.com:ip:clk_vip dut_clk
    set_property -dict [list CONFIG.INTERFACE_MODE {PASS_THROUGH}] [get_bd_cells dut_clk]
    connect_bd_net [get_bd_pins $device_clk] [get_bd_pins dut_clk/clk_in]

    # DUT-side reset: CPU reset synchronized to the device clock.
    create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset dut_rstgen
    connect_bd_net [get_bd_pins dut_clk/clk_out] [get_bd_pins dut_rstgen/slowest_sync_clk]
    connect_bd_net [get_bd_pins ${cpu_interconnect}/aresetn] [get_bd_pins dut_rstgen/ext_reset_in]

    create_bd_cell -type ip -vlnv xilinx.com:ip:axi_clock_converter dut_axi_cdc
    set_property -dict [list CONFIG.PROTOCOL {AXI4LITE} CONFIG.ACLK_ASYNC {1}] [get_bd_cells dut_axi_cdc]
    connect_bd_intf_net [get_bd_intf_pins ${cpu_interconnect}/${master_port}] [get_bd_intf_pins dut_axi_cdc/S_AXI]
    connect_bd_net [get_bd_pins ${cpu_interconnect}/aclk] [get_bd_pins dut_axi_cdc/s_axi_aclk]
    connect_bd_net [get_bd_pins ${cpu_interconnect}/aresetn] [get_bd_pins dut_axi_cdc/s_axi_aresetn]
    connect_bd_net [get_bd_pins dut_clk/clk_out] [get_bd_pins dut_axi_cdc/m_axi_aclk]
    connect_bd_net [get_bd_pins dut_rstgen/peripheral_aresetn] [get_bd_pins dut_axi_cdc/m_axi_aresetn]
}

 proc preprocess_bd {project carrier rxtx} {
    puts "Preprocessing $project $carrier $rxtx"

    # hdl_2026_r1 names CPU interconnects after the processor's AXI master.
    switch $carrier {
        zcu102 {set cpu_interconnect axi_hpm0_lpd_interconnect}
        zc706 {set cpu_interconnect axi_gp0_interconnect}
        vcu118 {set cpu_interconnect axi_dp_interconnect}
        default {error "Unsupported carrier $carrier"}
    }

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
                    set_property -dict [list CONFIG.NUM_CLKS {2}] [get_bd_cells ${cpu_interconnect}]
                    if {$rxtx == "rx" || $rxtx == "rxtx"} {
                        set_property -dict [list CONFIG.NUM_MI {12}] [get_bd_cells ${cpu_interconnect}]
                        connect_bd_net [get_bd_pins ${cpu_interconnect}/aclk1] [get_bd_pins util_daq2_xcvr/rx_out_clk_0]
                    }
                    if {$rxtx == "tx"} {
                        set_property -dict [list CONFIG.NUM_MI {12}] [get_bd_cells ${cpu_interconnect}]
                        connect_bd_net [get_bd_pins ${cpu_interconnect}/aclk1] [get_bd_pins util_daq2_xcvr/tx_out_clk_0]
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
                        set_property -dict [list CONFIG.NUM_MI {9}] [get_bd_cells ${cpu_interconnect}]
                        connect_bd_net [get_bd_pins ${cpu_interconnect}/M08_ACLK] [get_bd_pins axi_ad9434/adc_clk]
                        connect_bd_net [get_bd_pins sys_rstgen/peripheral_aresetn] [get_bd_pins ${cpu_interconnect}/M08_ARESETN]
                    }
                }
            }
        }
        ad9081_fmca_ebz {
            # The DUT and its AXI-Lite slave run on the device clocks (2.58 ns
            # in the upstream timing constraints).
            make_clock_port rx_device_clk 387596899
            make_clock_port tx_device_clk 387596899

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
                # Connect TX clocking to the RX device clock

                # Reset reconnect
                delete_bd_objs [get_bd_nets -of_objects [get_bd_ports tx_device_clk]]
                connect_bd_net [get_bd_pins tx_device_clk_rstgen/slowest_sync_clk] [get_bd_ports rx_device_clk]

                # UPACK reconnect
                connect_bd_net [get_bd_pins util_mxfe_upack/clk] [get_bd_ports rx_device_clk]

                # DAC FIFO reconnect
                connect_bd_net [get_bd_pins mxfe_tx_data_offload/m_axis_aclk] [get_bd_ports rx_device_clk]

                # TX TPL Core
                connect_bd_net [get_bd_pins tx_mxfe_tpl_core/link_clk] [get_bd_ports rx_device_clk]

                # TX JESD
                connect_bd_net [get_bd_pins axi_mxfe_tx_jesd/device_clk] [get_bd_ports rx_device_clk]

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
                    set_property -dict [list CONFIG.NUM_CLKS {2}] [get_bd_cells ${cpu_interconnect}]
	            if {$rxtx == "rx" || $rxtx == "rxtx"} {
                        set_property -dict [list CONFIG.NUM_MI {12}] [get_bd_cells ${cpu_interconnect}]
                        connect_bd_net [get_bd_pins ${cpu_interconnect}/aclk1] [get_bd_ports rx_device_clk]
                    }
                    if {$rxtx == "tx"} {
                        set_property -dict [list CONFIG.NUM_MI {12}] [get_bd_cells ${cpu_interconnect}]
                        connect_bd_net [get_bd_pins ${cpu_interconnect}/aclk1] [get_bd_ports tx_device_clk]
                    }
                }
            }
        }
        ad9783_ebz {            
            if {$rxtx == "tx"} {
                # DATA PINS
                delete_bd_objs [get_bd_nets util_ad9783_dac_upack_fifo_rd_data_0]
                delete_bd_objs [get_bd_nets util_ad9783_dac_upack_fifo_rd_data_1]
            }
            switch $carrier {                
                zcu102 {                    
                    if {$rxtx == "tx"} {
                        # M03_AXI feeds the DUT AXI4-Lite through dut_axi_cdc.
                        set_property -dict [list CONFIG.NUM_MI {4}] [get_bd_cells ${cpu_interconnect}]
                        add_dut_axi_lite_cdc ${cpu_interconnect} M03_AXI axi_ad9783/dac_div_clk
                        # With the DUT added, dac_div_clk spans more clock
                        # regions and the placer moves its root away from the
                        # DAC OSERDES (X3Y2). The OSERDESE3 CLK/CLKDIV max-skew
                        # check then fails (the upstream design passes it).
                        # Root the divided clock in the OSERDES clock region.
                        add_project_xdc hsx_ad9783_clock_root.xdc {set_property USER_CLOCK_ROOT X3Y2 [get_nets -of_objects [get_pins -hierarchical -filter {NAME =~ */axi_ad9783/inst/i_if/i_dac_div_clk_rbuf/O}]]}
                    }
                }
            }
        }
        ad9208_dual_ebz {
            # The DUT and its AXI-Lite slave run on the global clock (2.66 ns
            # in the upstream timing constraints).
            make_clock_port glbl_clk_0 375939850

            if {$rxtx == "rx"} {
                # Disconnect the ADC PACK pins
                delete_bd_objs [get_bd_nets rx_ad9208_0_tpl_core_adc_valid_0]
                

                delete_bd_objs [get_bd_nets rx_ad9208_0_tpl_core_adc_data_0]
                delete_bd_objs [get_bd_nets rx_ad9208_0_tpl_core_adc_data_1]
                delete_bd_objs [get_bd_nets rx_ad9208_1_tpl_core_adc_data_0]
                delete_bd_objs [get_bd_nets rx_ad9208_1_tpl_core_adc_data_1]
                
            }
            switch $carrier {                
                vcu118 {     
                    set_property -dict [list  CONFIG.NUM_CLKS {3}] [get_bd_cells ${cpu_interconnect}]
                    if {$rxtx == "rx"} {
                        # M00-M17 are occupied by the upstream VCU118/AD9208 design.
                        set_property -dict [list CONFIG.NUM_MI {19}] [get_bd_cells ${cpu_interconnect}]
                        connect_bd_net [get_bd_pins ${cpu_interconnect}/aclk2] [get_bd_pins glbl_clk_0]
                    }
                }
            }
        }       
    }
}

