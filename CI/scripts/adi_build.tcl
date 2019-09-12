global fpga_board

if {[info exists fpga_board]} {
    puts "==========="
    puts $fpga_board
    puts "==========="
} else {
    # Set to something not ZCU102
    set fpga_board "ZYNQ"
}

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
file copy -force vivado_prj.runs/impl_1/system_top.sysdef $sdk_loc/system_top.hdf

# Close the Vivado project
close_project

# Create the BOOT.bin
if {$fpga_board eq "ZCU102"} {

    ### Copy common boot files
    file copy -force $cdir/projects/common/boot/zynqmp.bif $cdir/boot/zynqmp.bif
    file copy -force $cdir/projects/common/boot/bl31.elf $cdir/boot/bl31.elf
    file copy -force $cdir/projects/common/boot/pmufw.elf $cdir/boot/pmufw.elf
    file copy -force $cdir/projects/common/boot/fsbl.elf $cdir/boot/fsbl.elf
    file copy -force $cdir/projects/common/boot/u-boot-zcu.elf $cdir/boot/u-boot-zcu.elf

    ### Copy system_top.bit into the output folder
    file copy -force vivado_prj.runs/impl_1/system_top.bit $cdir/boot/system_top.bit

    # Generate BOOT.bin File
    cd $cdir/boot
    exec bootgen -arch zynqmp -image zynqmp.bif -o BOOT.BIN -w
    cd $cdir
    if {[file exist boot/BOOT.BIN] eq 0} {
        puts "ERROR: BOOT.BIN not built"
        return -code error 11
    } else {
        puts "BOOT.BIN built correctly!"
    }

} else {
    exec xsdk -batch -source $cdir/projects/scripts/fsbl_build_zynq.tcl
    if {[file exist boot/BOOT.BIN] eq 0} {
        puts "ERROR: BOOT.BIN not built"
        return -code error 11
    } else {
        puts "BOOT.BIN built correctly!"
    }
}

puts "------------------------------------"
puts "Embedded system build completed."
puts "You may close this shell."
puts "------------------------------------"
exit
