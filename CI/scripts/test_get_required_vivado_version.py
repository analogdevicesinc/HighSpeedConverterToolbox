from pathlib import Path
from tempfile import TemporaryDirectory
import unittest

from CI.scripts.get_required_vivado_version import get_required_vivado_version


class GetRequiredVivadoVersionTests(unittest.TestCase):
    def parse(self, content: str) -> str:
        with TemporaryDirectory() as tmp:
            path = Path(tmp, "version.tcl")
            path.write_text(content, encoding="utf-8")
            return get_required_vivado_version(path)

    def test_parses_current_adi_env_format(self):
        self.assertEqual(
            self.parse('set required_vivado_version "2025.1"\n'), "2025.1"
        )

    def test_parses_legacy_unquoted_format(self):
        self.assertEqual(self.parse("set required_vivado_version 2022.2\n"), "2022.2")

    def test_rejects_missing_declaration(self):
        with self.assertRaises(ValueError):
            self.parse("set other_version 2025.1\n")


if __name__ == "__main__":
    unittest.main()
