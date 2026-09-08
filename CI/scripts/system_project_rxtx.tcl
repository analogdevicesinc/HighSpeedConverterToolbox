set start_dir [pwd]
# adi_make::lib sources library Makefiles which may reuse these global Tcl
# variable names. Preserve the HDL Coder reference-design parameters so the
# post-build block-design preprocessing targets the requested carrier.
set matlab_project $project
set matlab_carrier $carrier
set matlab_ref_design $ref_design
puts "Starting High-Speed Converter Toolbox HDL build"

if {$preprocess == "on"} {
    source $preprocess_script
}

cd projects/$project/$carrier
source ../../scripts/adi_make.tcl
adi_make::lib all

set ::env(SKIP_SYNTHESIS) 1
set ::env(ADI_SKIP_SYNTHESIS) 1
set ::env(MATLAB) 1
# hdl_2026_r1 renamed the HDL Coder in-memory-project contract from the legacy
# MATLAB env var to ADI_MATLAB inside adi_project_xilinx.tcl. Set both so the
# reference design reuses HDL Coder's project (instead of calling create_project)
# regardless of which HDL branch supplies adi_project_xilinx.tcl.
set ::env(ADI_MATLAB) 1
set ::env(ADI_USE_OOC_SYNTHESYS) 1

source ./system_project.tcl

# Update block design to make room for new IP. Restore the HDL Coder
# parameters because the library build can overwrite generic Tcl variables.
set project $matlab_project
set carrier $matlab_carrier
set ref_design $matlab_ref_design
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
