import unittest

from CI.scripts.patch_gtwiz_parser import (
    CAPTURE_LINE,
    GIT_BLOCK,
    SENTINEL,
    patch_text,
)


class PatchGtwizParserTests(unittest.TestCase):
    def test_replaces_git_dependency(self):
        updated = patch_text("sub xcvr_diff {\n" + CAPTURE_LINE + GIT_BLOCK)
        self.assertIn(SENTINEL, updated)
        self.assertIn("open(DIFFFILE", updated)
        self.assertNotIn("git status", updated)

    def test_is_idempotent(self):
        updated = patch_text("sub xcvr_diff {\n" + CAPTURE_LINE + GIT_BLOCK)
        self.assertEqual(patch_text(updated), updated)

    def test_rejects_unknown_source(self):
        with self.assertRaises(ValueError):
            patch_text("unexpected parser source")


if __name__ == "__main__":
    unittest.main()
