import tempfile
import unittest
from pathlib import Path

from CI.scripts.check_hw_junit import main


class CheckHardwareJUnitTests(unittest.TestCase):
    def write_report(self, body):
        directory = tempfile.TemporaryDirectory()
        self.addCleanup(directory.cleanup)
        report = Path(directory.name) / "results.xml"
        report.write_text(f"<testsuite>{body}</testsuite>", encoding="utf-8")
        return report

    def test_accepts_complete_passing_report(self):
        report = self.write_report("<testcase/><testcase/>")
        self.assertEqual(main(["--minimum-tests", "2", str(report)]), 0)

    def test_rejects_skipped_report(self):
        report = self.write_report("<testcase><skipped/></testcase>")
        self.assertEqual(main([str(report)]), 1)

    def test_rejects_failed_report(self):
        report = self.write_report("<testcase><failure/></testcase>")
        self.assertEqual(main([str(report)]), 1)

    def test_rejects_too_few_tests(self):
        report = self.write_report("<testcase/>")
        self.assertEqual(main(["--minimum-tests", "2", str(report)]), 1)

    def test_rejects_missing_report(self):
        self.assertEqual(main(["missing.xml"]), 1)


if __name__ == "__main__":
    unittest.main()
