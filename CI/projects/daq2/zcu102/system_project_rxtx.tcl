set ad_hdl_dir    	[pwd]
set ad_phdl_dir   	[pwd]
set proj_dir		$ad_hdl_dir/projects/daq2/zcu102

source $ad_hdl_dir/projects/scripts/adi_project.tcl
source $ad_hdl_dir/projects/scripts/adi_board.tcl

adi_project_xilinx daq2_zcu102 $proj_dir config_rxtx.tcl
adi_project_files daq2_zcu102 [list \
  "$ad_hdl_dir/projects/daq2/common/daq2_spi.v" \
  "system_top.v" \
  "system_constr.xdc"\
  "$ad_hdl_dir/library/xilinx/common/ad_iobuf.v" \
  "$ad_hdl_dir/projects/common/zcu102/zcu102_system_constr.xdc" ]

adi_project_run daq2_zcu102

# Copy the boot file to the root directory
file copy -force $proj_dir/boot $ad_hdl_dir/boot