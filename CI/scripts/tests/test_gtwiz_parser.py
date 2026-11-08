"""Exercise the actual upstream Perl function in metadata-free HDL snapshots."""

from pathlib import Path
import shutil
import subprocess
import sys
import tempfile
import unittest

SCRIPTS = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(SCRIPTS))
from patch_gtwiz_parser import patch_text


class GtwizPatchTests(unittest.TestCase):
    def setUp(self):
        self.original = (SCRIPTS / 'tests/fixtures/xcvr_diff.pl').read_text()

    def test_idempotence_and_unknown_upstream(self):
        patched = patch_text(self.original)
        self.assertEqual(patch_text(patched), patched)
        with self.assertRaises(ValueError):
            patch_text('sub xcvr_diff { changed_upstream(); }')

    @unittest.skipUnless(shutil.which('perl') and shutil.which('git'), 'Perl and Git required')
    def test_diff_preserves_hdl_with_or_without_parent_repository(self):
        for repository in (False, True):
            with self.subTest(repository=repository), tempfile.TemporaryDirectory() as scratch:
                root = Path(scratch)
                if repository:
                    subprocess.run(['git', 'init', '-q', str(root)], check=True)
                folder = root / 'snapshot with spaces'
                folder.mkdir()
                original = 'GTHE4_CHANNEL #(\n  .CPLL_FBDIV (2),\n  .UNCHANGED (1)\n) i_GTHE4_CHANNEL ();\n'
                hdl = folder / 'util_adxcvr_xch.v'
                hdl.write_text(original)
                script = folder / 'test.pl'
                script.write_text(patch_text(self.original) + r'''
my %attributes = (CPLL_FBDIV => 4);
xcvr_diff('util_adxcvr_xch.v', 'GTHE4_CHANNEL', \%attributes);
''')
                result = subprocess.run(['perl', str(script)], cwd=folder, capture_output=True, text=True)
                self.assertEqual(result.returncode, 0, result.stderr)
                self.assertEqual(hdl.read_text(), original)
                self.assertEqual((folder / 'util_adxcvr_xch.diff').read_text(),
                                 '-  .CPLL_FBDIV (2),\n+  .CPLL_FBDIV (4),\n')
                self.assertNotIn('not an HDL repository', result.stdout)


if __name__ == '__main__':
    unittest.main()
