global ref_design

# Add 1 extra AXI master ports to the interconnect
set_property -dict [list CONFIG.NUM_MI {9}] [get_bd_cells axi_cpu_interconnect]

if {$ref_design eq "Rx" || $ref_design eq "Rx & Tx"} {
    connect_bd_net [get_bd_pins axi_cpu_interconnect/M08_ARESETN] [get_bd_pins axi_ad9680_jesd_rstgen/interconnect_aresetn]
}
if {$ref_design eq "Tx"} {
    connect_bd_net [get_bd_pins axi_cpu_interconnect/M08_ARESETN] [get_bd_pins axi_ad9144_jesd_rstgen/interconnect_aresetn]
}