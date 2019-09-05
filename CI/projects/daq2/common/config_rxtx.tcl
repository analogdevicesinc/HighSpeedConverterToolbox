global ref_design
global fpga_board

if {$ref_design eq "Rx" || $ref_design eq "Rx & Tx"} {
    # Disconnect the ADC PACK pins
    disconnect_bd_net /axi_ad9680_core_adc_valid_0 [get_bd_pins axi_ad9680_cpack/adc_valid_0]
    disconnect_bd_net /axi_ad9680_core_adc_valid_1 [get_bd_pins axi_ad9680_cpack/adc_valid_1]

    disconnect_bd_net /axi_ad9680_core_adc_data_0 [get_bd_pins axi_ad9680_cpack/adc_data_0]
    disconnect_bd_net /axi_ad9680_core_adc_data_1 [get_bd_pins axi_ad9680_cpack/adc_data_1]

    # Connect the ADC PACK valid signals together
    connect_bd_net [get_bd_pins axi_ad9680_cpack/adc_valid_0] [get_bd_pins axi_ad9680_cpack/adc_valid_1]
}

########################

if {$ref_design eq "Tx" || $ref_design eq "Rx & Tx"} {
    # Disconnect the DAC PACK pins
    # VALID PINS NOT CONNECTED TO INTERFACE CORE ON DAC SIDE

    # DATA PINS
    disconnect_bd_net /axi_ad9144_upack_dac_data_0 [get_bd_pins axi_ad9144_core/dac_ddata_0]
    disconnect_bd_net /axi_ad9144_upack_dac_data_1 [get_bd_pins axi_ad9144_core/dac_ddata_1]

}

# Connect clock
if {$fpga_board eq "ZCU102"} {

    if {$ref_design eq "Rx" || $ref_design eq "Rx & Tx"} {
        connect_bd_net [get_bd_pins axi_cpu_interconnect/M08_ACLK] [get_bd_pins util_daq2_xcvr/rx_out_clk_0]
#        connect_bd_net [get_bd_pins axi_cpu_interconnect/M08_ACLK] [get_bd_pins sys_ps8/pl_clk0]
#        connect_bd_net [get_bd_pins axi_cpu_interconnect/M8_ACLK] [get_bd_pins axi_adrv9009_rx_clkgen/clk_0]
    }

    if {$ref_design eq "Tx"} {
        connect_bd_net [get_bd_pins axi_cpu_interconnect/M08_ACLK] [get_bd_pins sys_ps8/pl_clk0]
 #       connect_bd_net [get_bd_pins axi_cpu_interconnect/M8_ACLK] [get_bd_pins axi_adrv9009_tx_clkgen/clk_0]
    }
}