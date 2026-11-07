"""Check Tcl integration contracts with vendor commands stubbed out."""

from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest


SCRIPTS = Path(__file__).resolve().parents[1]


@unittest.skipUnless(shutil.which('tclsh'), 'tclsh is required')
class TclIntegrationTests(unittest.TestCase):
    def run_tcl(self, root, code):
        script = root / 'test.tcl'
        script.write_text(code)
        return subprocess.run(['tclsh', str(script)], cwd=root, capture_output=True, text=True)

    def test_matlab_project_uses_upstream_build_flags(self):
        with tempfile.TemporaryDirectory() as scratch:
            root = Path(scratch)
            project = root / 'projects/daq2/zcu102'
            project.mkdir(parents=True)
            scripts = root / 'projects/scripts'
            scripts.mkdir()
            (scripts / 'adi_make.tcl').write_text('namespace eval adi_make {proc lib args {}}\n')
            (scripts / 'matlab_processors.tcl').write_text('''proc preprocess_bd {project carrier mode} {
    if {[list $project $carrier $mode] ne "daq2 zcu102 rx"} {error "Clobbered project context"}
}\n''')
            (project / 'system_project.tcl').write_text('''
foreach flag {ADI_MATLAB ADI_SKIP_SYNTHESIS ADI_USE_OOC_SYNTHESIS} {
    if {![info exists ::env($flag)] || !$::env($flag)} {
        error "Missing upstream flag $flag"
    }
}
set carrier c5soc
set project upstream_project
set ref_design upstream_mode
''')
            result = self.run_tcl(root, f'''
set project daq2
set carrier zcu102
set ref_design rx
set preprocess off
set postprocess off
proc regenerate_bd_layout {{}} {{}}
proc save_bd_design {{}} {{}}
proc validate_bd_design {{}} {{}}
source {{{SCRIPTS / 'system_project_rxtx.tcl'}}}
if {{[pwd] ne {{{root}}}}} {{error "Project did not restore working directory"}}
''')
            self.assertEqual(result.returncode, 0, result.stderr)

    def test_transceiver_subbuild_does_not_inherit_parent_flags(self):
        for fail in (0, 1):
            with self.subTest(fail=fail), tempfile.TemporaryDirectory() as scratch:
                root = Path(scratch)
                shutil.copyfile(SCRIPTS / 'adi_project_xilinx.tcl', root / 'adi_project_xilinx.tcl')
                (root / 'adi_project_xilinx_upstream.tcl').write_text('''
proc adi_xcvr_project {parameters} {
    foreach flag {ADI_MATLAB ADI_SKIP_SYNTHESIS MAKEFLAGS MAKEOVERRIDES MFLAGS GNUMAKEFLAGS} {
        if {[info exists ::env($flag)]} {error "Leaked parent flag $flag"}
    }
    if {$::env(MAKELEVEL) != 1} {error "Wrong nested make parameter order"}
    if {$::fail} {error "Transceiver build failed"}
    return $parameters
}
''')
                result = self.run_tcl(root, f'''
set ::env(ADI_MATLAB) 1
set ::env(ADI_SKIP_SYNTHESIS) 1
foreach flag {{MAKEFLAGS MAKEOVERRIDES MFLAGS MAKELEVEL GNUMAKEFLAGS}} {{set ::env($flag) 1}}
set fail {fail}
source adi_project_xilinx.tcl
# Loading another reference design in the same Vivado session must also work.
source adi_project_xilinx.tcl
set status [catch {{adi_xcvr_project {{LANE_RATE 10}}}} result]
if {{$status != {fail}}} {{error "Unexpected sub-build result: $result"}}
if {{{fail} && $result ne "Transceiver build failed"}} {{error $result}}
if {{!{fail} && $result ne "LANE_RATE 10"}} {{error "Lost helper return value"}}
foreach flag {{ADI_MATLAB ADI_SKIP_SYNTHESIS MAKEFLAGS MAKEOVERRIDES MFLAGS MAKELEVEL GNUMAKEFLAGS}} {{
    if {{![info exists ::env($flag)] || $::env($flag) ne "1"}} {{
        error "Parent flag was not restored: $flag"
    }}
}}
''')
                self.assertEqual(result.returncode, 0, result.stderr)

    @unittest.skipUnless(shutil.which('make'), 'make is required')
    def test_outer_make_arguments_do_not_change_transceiver_configuration(self):
        with tempfile.TemporaryDirectory() as scratch:
            root = Path(scratch)
            shutil.copyfile(SCRIPTS / 'adi_project_xilinx.tcl', root / 'adi_project_xilinx.tcl')
            (root / 'child.mk').write_text('''ifeq ($(shell expr $(MAKELEVEL) % 2),0)
CMD_VARIABLES := $(shell echo $(-*-command-variables-*-) | tac -s ' ')
else
CMD_VARIABLES := $(shell echo $(MAKEOVERRIDES))
endif
all:
\t@echo $(CMD_VARIABLES)
''')
            (root / 'adi_project_xilinx_upstream.tcl').write_text('''
proc adi_xcvr_project {parameters} {
    return [exec make --no-print-directory -f child.mk {*}$parameters]
}
''')
            result = self.run_tcl(root, '''
set ::env(MAKEFLAGS) { -- BOARD=daq2}
set ::env(MAKEOVERRIDES) {BOARD=daq2}
set ::env(MAKELEVEL) 1
source adi_project_xilinx.tcl
set result [adi_xcvr_project {LANE_RATE=10 REF_CLK=500 PLL_TYPE=QPLL0}]
if {[string match *BOARD* $result]} {error "Outer BOARD contaminated the transceiver: $result"}
if {![string match *LANE_RATE=10* $result]} {error "Lost transceiver parameters: $result"}
if {[string trim $result] ne "PLL_TYPE=QPLL0 REF_CLK=500 LANE_RATE=10"} {
    error "Transceiver output directory parameter order changed: $result"
}
if {$::env(MAKEOVERRIDES) ne "BOARD=daq2"} {error "Lost outer make arguments"}
''')
            self.assertEqual(result.returncode, 0, result.stderr)

    def boot_build(self, entrypoint, board, missing_files=False, failure=""):
        with tempfile.TemporaryDirectory() as scratch:
            root = Path(scratch)
            scripts = root / 'projects/scripts'
            scripts.mkdir(parents=True)
            for name in ('adi_build.tcl', 'adi_build_win.tcl'):
                shutil.copyfile(SCRIPTS / name, scripts / name)
            if not missing_files:
                shutil.copytree(SCRIPTS / 'boot', root / 'projects/common/boot')
            bitstream = root / 'vivado_prj.runs/impl_1/system_top.bit'
            bitstream.parent.mkdir(parents=True)
            bitstream.write_text('stub bitstream')
            return self.run_tcl(root, f'''
# No synthesis is performed: only boot-file staging and tool dispatch are tested.
foreach command {{update_compile_order reset_run set_property export_ip_user_files
                  launch_runs wait_on_run write_hw_platform close_project}} {{
    proc $command args {{}}
}}
proc get_files args {{return system.bd}}
proc exec args {{
    if {{[lindex $args 0] ne "bootgen"}} {{error "Unexpected legacy tool: $args"}}
    puts "BOOTGEN_ARCH=[lindex $args 2]"
    foreach file {{fsbl.elf u-boot.elf system_top.bit zynq.bif}} {{
        if {{![file exists $file]}} {{error "Missing boot input $file"}}
    }}
    if {{[lindex $args 2] eq "zynqmp"}} {{
        foreach file {{bl31.elf pmufw.elf}} {{
            if {{![file exists $file]}} {{error "Missing boot input $file"}}
        }}
    }}
    close [open BOOT.BIN w]
}}
proc exit args {{}}
proc get_runs {{name}} {{return $name}}
proc get_property {{property object}} {{
    switch $property {{
        PROGRESS {{if {{"{failure}" eq "incomplete"}} {{return "50%"}}; return "100%"}}
        STATUS {{if {{"{failure}" eq "status"}} {{return "write_bitstream ERROR"}}; return "write_bitstream Complete!"}}
        DIRECTORY {{return "vivado_prj.runs/impl_1"}}
        SLACK {{
            if {{"{failure}" eq "timing" || ("{failure}" eq "hold" && $::delay_type eq "min")}} {{return -0.1}}
            return 0.1
        }}
    }}
}}
proc open_run args {{}}
proc report_timing_summary args {{}}
proc check_timing args {{}}
proc get_timing_paths args {{
    set ::delay_type [lindex $args 1]
    if {{"{failure}" eq "no_paths"}} {{return {{}}}}
    return path0
}}
set fpga_board {board}
set project daq2
set carrier {board}
source {{{scripts / entrypoint}}}
if {{"{board}" ne "vcu118" && ![file exists boot/BOOT.BIN] && ![file exists BOOT.BIN]}} {{
    error "BOOT.BIN was not produced"
}}
''')

    def test_preprocessing_uses_current_cpu_interconnect_names(self):
        designs = (('daq2', 'zcu102', 'rx', 'axi_hpm0_lpd_interconnect'),
                   ('ad9081_fmca_ebz', 'zcu102', 'rx', 'axi_hpm0_lpd_interconnect'),
                   ('ad9434_fmc', 'zc706', 'rx', 'axi_gp0_interconnect'),
                   ('ad9783_ebz', 'zcu102', 'tx', 'axi_hpm0_lpd_interconnect'),
                   ('ad9208_dual_ebz', 'vcu118', 'rx', 'axi_dp_interconnect'))
        for project, board, mode, expected in designs:
            with self.subTest(project=project), tempfile.TemporaryDirectory() as scratch:
                result = self.run_tcl(Path(scratch), f'''
proc check_interconnect {{name}} {{
    if {{[string match "axi_*interconnect*" $name] &&
         ![string match "{expected}*" $name]}} {{
        error "Obsolete CPU interconnect: $name"
    }}
    return $name
}}
proc get_bd_cells {{name}} {{return [check_interconnect $name]}}
proc get_bd_pins {{args}} {{return [check_interconnect [lindex $args end]]}}
proc get_bd_nets {{args}} {{return [lindex $args end]}}
proc get_bd_ports {{name}} {{return $name}}
foreach command {{disconnect_bd_net connect_bd_net delete_bd_objs set_property create_bd_cell create_bd_port}} {{
    proc $command args {{}}
}}
source {{{SCRIPTS / 'matlab_processors.tcl'}}}
preprocess_bd {project} {board} {mode}
''')
                self.assertEqual(result.returncode, 0, result.stderr)

    def test_boot_generation_uses_bundled_files_on_both_platforms(self):
        for entrypoint in ('adi_build.tcl', 'adi_build_win.tcl'):
            for board, arch in (('zc706', 'zynq'), ('zcu102', 'zynqmp'), ('vcu118', None)):
                with self.subTest(entrypoint=entrypoint, board=board):
                    result = self.boot_build(entrypoint, board)
                    self.assertEqual(result.returncode, 0, result.stderr)
                    if arch:
                        self.assertIn(f'BOOTGEN_ARCH={arch}', result.stdout)
                    else:
                        self.assertNotIn('BOOTGEN_ARCH=', result.stdout)

    def test_failed_implementation_or_timing_is_fatal(self):
        for failure in ('incomplete', 'status', 'timing', 'hold', 'no_paths'):
            with self.subTest(failure=failure):
                result = self.boot_build('adi_build.tcl', 'zcu102', failure=failure)
                self.assertNotEqual(result.returncode, 0)
                self.assertNotIn('BOOTGEN_ARCH=', result.stdout)

    def test_missing_boot_files_fail_clearly(self):
        result = self.boot_build('adi_build.tcl', 'zcu102', missing_files=True)
        self.assertNotEqual(result.returncode, 0)
        self.assertIn('Missing u-boot.elf', result.stderr)

    def test_ad9208_reserves_a_master_after_all_upstream_peripherals(self):
        with tempfile.TemporaryDirectory() as scratch:
            result = self.run_tcl(Path(scratch), f'''
proc get_bd_cells {{name}} {{return $name}}
proc get_bd_pins {{args}} {{return [lindex $args end]}}
proc get_bd_nets {{args}} {{return [lindex $args end]}}
proc get_bd_ports {{name}} {{return $name}}
proc delete_bd_objs args {{}}
proc connect_bd_net args {{}}
proc create_bd_port args {{}}
proc set_property {{option properties cell}} {{
    if {{[dict exists $properties CONFIG.NUM_MI]}} {{
        # 10 VCU118 base peripherals plus 8 AD9208 peripherals already use M00-M17.
        if {{[dict get $properties CONFIG.NUM_MI] != 19}} {{
            error "The MATLAB master would overwrite an upstream peripheral"
        }}
    }}
}}
source {{{SCRIPTS / 'matlab_processors.tcl'}}}
preprocess_bd ad9208_dual_ebz vcu118 rx
''')
            self.assertEqual(result.returncode, 0, result.stderr)


if __name__ == '__main__':
    unittest.main()
