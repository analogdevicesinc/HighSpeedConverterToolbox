#!/usr/bin/env python3
"""Make the HDL transceiver parser work in packaged, non-Git snapshots."""

from __future__ import annotations

import sys
from pathlib import Path


CAPTURE_LINE = "  close(READFILE) or die print \"@[$myname] Can not close file called $pfile.\\n\";\n"
CAPTURE_REPLACEMENT = CAPTURE_LINE + "  my @Original = @File;\n"
GIT_BLOCK = """  # Try to open file for write
  open(WRITEFILE, \">$pfile\") or die print \"@[$myname] Can not open file called $pfile for writing.\\n\";

  foreach my $line (@File){
    print WRITEFILE $line;
  }
  close(WRITEFILE) or die print \"@[$myname] Can not close file called $pfile.\\n\";

  ## save the diff between the current and updated XCVR files
  my $file_name = $pfile;
  $file_name =~ s/^.*\\///;
  $file_name =~ s/\\.v$//;

  my $check_git = `git status`;
  if ($check_git =~ m/On branch/i) {
    system \"git diff $pfile > $file_name.diff\";
    system \"git checkout -- $pfile\";
  } else {
    print \"WARNING: ADI's util_xcvr's can not be updated, because the current direcotry is NOT an HDL repository!\\n\";
  }
"""
DIRECT_DIFF_BLOCK = """  ## Save the changed attributes without requiring a Git worktree. The
  ## packaged MATLAB BSP intentionally excludes HDL repository metadata.
  my $file_name = $pfile;
  $file_name =~ s/^.*\\///;
  $file_name =~ s/\\.v$//;
  open(DIFFFILE, \">$file_name.diff\") or die print \"@[$myname] Can not open file called $file_name.diff for writing.\\n\";
  for my $i (0 .. $#File) {
    if ($Original[$i] ne $File[$i]) {
      print DIFFFILE \"-$Original[$i]\";
      print DIFFFILE \"+$File[$i]\";
    }
  }
  close(DIFFFILE) or die print \"@[$myname] Can not close file called $file_name.diff.\\n\";
"""
SENTINEL = "my @Original = @File;"


def patch_text(text: str) -> str:
    if SENTINEL in text:
        return text
    function_start = text.find("sub xcvr_diff {")
    capture_start = text.find(CAPTURE_LINE, function_start)
    if function_start < 0 or capture_start < 0:
        raise ValueError("xcvr_diff read block not found")
    if text.count(GIT_BLOCK) != 1:
        raise ValueError("expected exactly one Git-based xcvr_diff block")
    capture_end = capture_start + len(CAPTURE_LINE)
    text = text[:capture_start] + CAPTURE_REPLACEMENT + text[capture_end:]
    return text.replace(GIT_BLOCK, DIRECT_DIFF_BLOCK)


def main() -> int:
    path = Path(sys.argv[1])
    try:
        original = path.read_text()
        updated = patch_text(original)
    except (OSError, ValueError) as error:
        print(f"ERROR: unable to patch {path}: {error}", file=sys.stderr)
        return 1
    if updated != original:
        path.write_text(updated)
        print(f"patched non-Git xcvr diff generation into {path}")
    else:
        print(f"non-Git xcvr diff generation already present in {path}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
