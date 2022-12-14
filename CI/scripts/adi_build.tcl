global fpga_board

if {[info exists fpga_board]} {
    puts "==========="
    puts $fpga_board
    puts "==========="
} else {
    # Set to something not ZCU102
    set fpga_board "ZYNQ"
}

set prj_carrier $project$carrier

# Build the project
update_compile_order -fileset sources_1
reset_run impl_1
reset_run synth_1
launch_runs synth_1
wait_on_run synth_1
launch_runs impl_1 -to_step write_bitstream
wait_on_run impl_1

# Define local variables
set cdir [pwd]
set sdk_loc vivado_prj.sdk

# Export the hdf
file delete -force $sdk_loc
file mkdir $sdk_loc
write_hw_platform -fixed -force  -include_bit -file $sdk_loc/system_top.xsa

# Close the Vivado project
close_project

set arm_tr_frm_elf $cdir/projects/common/boot/bl31.elf

set xsct_script "exec xsct $cdir/projects/scripts/adi_make_boot_bin.tcl"
if {$fpga_board eq "ZCU102"} {
  set uboot_elf $cdir/projects/common/boot/u-boot-zcu.elf
} else {
  set uboot_elf $cdir/projects/common/boot/u-boot.elf
}
set build_args "$sdk_loc/system_top.xsa $uboot_elf $cdir/boot $arm_tr_frm_elf"
puts "Please wait, this may take a few minutes."
eval $xsct_script $build_args


puts "------------------------------------"
puts "Embedded system build completed."
puts "You may close this shell."
puts "------------------------------------"
exit
