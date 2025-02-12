set start_dir [pwd]
puts "Starting High-Speed Converter Toolbox HDL build"

if {$preprocess == "on"} {
    source $preprocess_script
}

cd projects/$project/$carrier
source ../../scripts/adi_make.tcl
adi_make::lib all

set ::env(ADI_SKIP_SYNTHESIS) 1
set ::env(SKIP_SYNTHESIS) 1
set ::env(ADI_MATLAB) 1
set ::env(MATLAB) 1
set ::env(ADI_USE_OOC_SYNTHESYS) 1
set ::env(ADI_IGNORE_VERSION_CHECK) 1

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
