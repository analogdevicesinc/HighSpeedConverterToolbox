set start_dir [pwd]
puts "Starting High-Speed Converter Toolbox HDL build"

if {$preprocess == "on"} {
    source $preprocess_script
}

cd projects/$project/$carrier
source ../../scripts/adi_make.tcl
adi_make::lib all

set ::env(SKIP_SYNTHESIS) 1
set ::env(MATLAB) 1
set ::env(JESD_MODE) $JESD_MODE
set ::env(RX_LANE_RATE) $RX_LANE_RATE
set ::env(TX_LANE_RATE) $TX_LANE_RATE
set ::env(RX_JESD_M) $RX_JESD_M
set ::env(RX_JESD_L) $RX_JESD_L
set ::env(RX_JESD_S) $RX_JESD_S
set ::env(RX_JESD_NP) $RX_JESD_NP
set ::env(RX_NUM_LINKS) $RX_NUM_LINKS
set ::env(TX_JESD_M) $TX_JESD_M
set ::env(TX_JESD_L) $TX_JESD_L
set ::env(TX_JESD_S) $TX_JESD_S
set ::env(TX_JESD_NP) $TX_JESD_NP
set ::env(TX_NUM_LINKS) $TX_NUM_LINKS
set ::env(TDD_SUPPORT) $TDD_SUPPORT
set ::env(SHARED_DEVCLK) $SHARED_DEVCLK

source ./system_project.tcl

# Update block design to make room for new IP
source ../../scripts/matlab_processors.tcl
preprocess_bd $project $carrier $ref_design

if {$postprocess == "on"} {
    cd $start_dir
    source $postprocess_script
}

regenerate_bd_layout
save_bd_design
validate_bd_design

# Back to root
cd $start_dir
