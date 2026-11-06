"""Exercise HDL dependency preparation without MATLAB, Vivado, or network access."""

import os
from pathlib import Path
import re
import shutil
import subprocess
import sys
import tempfile
import unittest


SCRIPTS = Path(__file__).resolve().parents[1]


class BuildBSPTests(unittest.TestCase):
    def setUp(self):
        self.scratch = tempfile.TemporaryDirectory()
        self.addCleanup(self.scratch.cleanup)
        self.root = Path(self.scratch.name)
        self.scripts = self.root / 'CI' / 'scripts'
        shutil.copytree(SCRIPTS, self.scripts)
        (self.root / 'hdl/vendor/AnalogDevices/+AnalogDevices').mkdir(parents=True)
        registry = SCRIPTS.parents[1] / 'hdl/vendor/AnalogDevices/hdlcoder_board_customization.m'
        shutil.copyfile(registry, self.root / 'hdl/vendor/AnalogDevices/hdlcoder_board_customization.m')
        self.fixture = self.root / 'upstream'
        for folder in ('scripts', 'projects/scripts', 'projects/common/board with spaces',
                       'projects/pluto', 'library/axi_ad9361'):
            (self.fixture / folder).mkdir(parents=True)
        self.version_file = self.fixture / 'scripts/adi_env.tcl'
        self.version_file.write_text(
            'set required_vivado_version "2025.1"\n'
            'if {[info exists ::env(REQUIRED_VIVADO_VERSION)]} {\n'
            '  set required_vivado_version $::env(REQUIRED_VIVADO_VERSION)\n'
            '} elseif {[info exists REQUIRED_VIVADO_VERSION]} {\n'
            '  set required_vivado_version $REQUIRED_VIVADO_VERSION\n}\n')
        self.project_file = self.fixture / 'projects/scripts/adi_project_xilinx.tcl'
        self.project_file.write_text('# Upstream MATLAB and transceiver support\n')
        for project, carrier in re.findall(r"'AnalogDevices\.([\w]+)\.([\w]+)\.plugin_board'",
                                          registry.read_text()):
            folder = self.fixture / 'projects' / project / carrier
            folder.mkdir(parents=True, exist_ok=True)
            for name in ('system_project.tcl', 'system_top.v', 'system_constr.xdc'):
                (folder / name).write_text('# Fixture project\n')
        common = self.fixture / 'projects/common/board with spaces'
        (common / 'memory.prj').write_text('memory contents\n')
        (common / 'system.tcl').write_text('set memory memory.prj\n')
        (self.fixture / 'projects/pluto/system_constr.xdc').write_text('period 16.27\n')
        self.bin = self.root / 'bin'
        self.bin.mkdir()
        git = self.bin / 'git'
        git.write_text(
            f'#!{sys.executable}\n'
            'import os, pathlib, shutil, sys\n'
            'pathlib.Path(os.environ["CLONE_ARGS"]).write_text(" ".join(sys.argv[1:]))\n'
            'if os.environ.get("FAIL_CLONE"):\n'
            '    sys.exit(1)\n'
            'shutil.copytree(os.environ["HDL_FIXTURE"], "hdl")\n')
        git.chmod(0o755)
        self.env = dict(os.environ, PATH=f'{self.bin}:{os.environ["PATH"]}',
                        HDL_FIXTURE=str(self.fixture), CLONE_ARGS=str(self.root / 'clone-args'))
        self.env.pop('HDLBRANCH', None)

    def prepare(self):
        return subprocess.run(['bash', 'build_bsp.sh'], cwd=self.scripts, env=self.env,
                              capture_output=True, text=True)

    def test_prepare_new_hdl_without_vendor_tools(self):
        result = self.prepare()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn('Required Vivado version 2025.1\n', result.stdout)
        self.assertIn('-b hdl_2026_r1', (self.root / 'clone-args').read_text())
        target = self.root / 'hdl/vendor/AnalogDevices/vivado'
        self.assertEqual((target / 'projects/scripts/adi_project_xilinx_upstream.tcl').read_text(),
                         self.project_file.read_text())
        common = target / 'projects/common/board with spaces'
        self.assertTrue((common / 'memory.mk').exists())
        self.assertFalse((common / 'memory.prj').exists())
        self.assertIn('memory.mk', (common / 'system.tcl').read_text())
        self.assertTrue((target / 'projects/common/boot/zcu102/zynq.bif').exists())

    def test_missing_version_fails_before_installing_hdl(self):
        self.version_file.write_text('# No version declaration\n')
        result = self.prepare()
        self.assertNotEqual(result.returncode, 0)
        self.assertIn('Cannot determine required Vivado version', result.stderr)
        self.assertFalse((self.root / 'hdl/vendor/AnalogDevices/vivado').exists())

    def test_malformed_version_fails(self):
        self.version_file.write_text('set required_vivado_version "invalid"\n')
        result = self.prepare()
        self.assertNotEqual(result.returncode, 0)
        self.assertIn('Cannot determine required Vivado version', result.stderr)

    def test_legacy_version_location_and_branch_override(self):
        self.version_file.unlink()
        legacy = self.fixture / 'library/scripts'
        legacy.mkdir()
        (legacy / 'adi_ip_xilinx.tcl').write_text('set required_vivado_version "2022.2"\n')
        self.env['HDLBRANCH'] = 'custom-branch'
        result = self.prepare()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn('Required Vivado version 2022.2\n', result.stdout)
        self.assertIn('-b custom-branch', (self.root / 'clone-args').read_text())

    def test_no_prj_files_is_valid(self):
        common = self.fixture / 'projects/common/board with spaces'
        shutil.rmtree(common)
        result = self.prepare()
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_clone_failure_is_fatal(self):
        self.env['FAIL_CLONE'] = '1'
        result = self.prepare()
        self.assertNotEqual(result.returncode, 0)
        self.assertIn('HDL clone failed', result.stdout + result.stderr)

    def test_missing_registered_project_is_fatal(self):
        (self.fixture / 'projects/daq2/zcu102/system_top.v').unlink()
        result = self.prepare()
        self.assertNotEqual(result.returncode, 0)
        self.assertIn('daq2/zcu102/system_top.v', result.stderr)


if __name__ == '__main__':
    unittest.main()
