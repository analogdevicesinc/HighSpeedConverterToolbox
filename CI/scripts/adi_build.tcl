# Define local variables
set cdir [pwd]
set sdk_loc vivado_prj.sdk
set project_system_dir vivado_prj.srcs/sources_1/bd/system
set prj_carrier $project$carrier

set fpga_board_lc [string tolower $fpga_board]

puts "FPGA Board: $fpga_board_lc"

if {$fpga_board_lc != "vcu118"} {
    # Verify support files exist
    if {![file exists $cdir/projects/common/boot/$fpga_board_lc/u-boot.elf]} {
        error "Missing u-boot.elf for $fpga_board_lc"
    }
}

# Build the project
update_compile_order -fileset sources_1
reset_run impl_1
reset_run synth_1
set_property synth_checkpoint_mode Hierarchical [get_files $project_system_dir/system.bd]
export_ip_user_files -of_objects [get_files $project_system_dir/system.bd] -no_script -sync -force -quiet
launch_runs synth_1
wait_on_run synth_1
if {[get_property PROGRESS [get_runs synth_1]] ne "100%" ||
    ![string match "*Complete*" [get_property STATUS [get_runs synth_1]]]} {
    error "Synthesis did not complete successfully"
}
launch_runs impl_1 -to_step write_bitstream
wait_on_run impl_1
if {[get_property PROGRESS [get_runs impl_1]] ne "100%" ||
    ![string match "*write_bitstream Complete*" [get_property STATUS [get_runs impl_1]]]} {
    error "Implementation did not complete successfully"
}
open_run impl_1
set report_dir [get_property DIRECTORY [get_runs impl_1]]
report_timing_summary -report_unconstrained -file $report_dir/hsx_timing_summary.rpt
check_timing -verbose -file $report_dir/hsx_check_timing.rpt
foreach delay_type {max min} {
    set paths [get_timing_paths -delay_type $delay_type -max_paths 1]
    if {[llength $paths] == 0} {
        error "No $delay_type timing paths were analyzed"
    }
    if {[get_property SLACK [lindex $paths 0]] < 0} {
        error "Routed $delay_type timing failed; see $report_dir/hsx_timing_summary.rpt"
    }
}
set marker [open $report_dir/hsx_build_verified.txt w]
puts $marker "Synthesis, implementation, setup and hold timing passed."
close $marker

# Export the hdf
file delete -force $sdk_loc
file mkdir $sdk_loc
write_hw_platform -fixed -force  -include_bit -file $sdk_loc/system_top.xsa

# Close the Vivado project
close_project

# Create the BOOT.bin
if {$fpga_board_lc != "vcu118"} {
    puts "Generating BOOT.BIN"
    puts "Please wait, this may take a few minutes."
    file mkdir $cdir/boot
    file copy -force $cdir/vivado_prj.runs/impl_1/system_top.bit $cdir/boot/system_top.bit
    file copy -force $cdir/projects/common/boot/$fpga_board_lc/u-boot.elf $cdir/boot/u-boot.elf
    file copy -force $cdir/projects/common/boot/$fpga_board_lc/zynq.bif $cdir/boot/zynq.bif
    file copy -force $cdir/projects/common/boot/$fpga_board_lc/fsbl.elf $cdir/boot/fsbl.elf

    if {$fpga_board_lc == "zcu102"} {
        file copy -force $cdir/projects/common/boot/$fpga_board_lc/bl31.elf $cdir/boot/bl31.elf
        file copy -force $cdir/projects/common/boot/$fpga_board_lc/pmufw.elf $cdir/boot/pmufw.elf
        cd $cdir/boot
        exec bootgen -arch zynqmp -image zynq.bif -o BOOT.BIN -w
    } else {
        cd $cdir/boot
        exec bootgen -arch zynq -image zynq.bif -o BOOT.BIN -w
    }
}

puts "------------------------------------"
puts "Embedded system build completed."
puts "You may close this shell."
puts "------------------------------------"
exit
