# Extracted from ADI HDL hdl_2026_r1 gtwiz_parser.pl for regression testing.
# Copyright (C) 2022-2023 Analog Devices, Inc. All rights reserved.
# SPDX-License-Identifier: ADIBSD
sub xcvr_diff {

  my ($pfile, $gt_type, $params_ref) = @_;
  my $myname = (caller(0))[3];

  # Try to open file for read
  if (not open(READFILE, "<$pfile")) {
    print "WARNING@[$myname] : Can not update $pfile ...\n";
    return 0;
  }

  my @File = "";
  while (my $fline = <READFILE>) {
    push(@File, $fline);
  }

  # Find the GT's attributes location in the file
  my $gt_paramblock_start = 0;
  my $gt_paramblock_end = 0;
  for my $i (0 .. $#File) {
    if ($File[$i] =~ m/\b$gt_type/i) {
      $gt_paramblock_start = $i;
    }
    if ($File[$i] =~ m/\bi_$gt_type/i) {
      $gt_paramblock_end = $i;
    }
  }
  close(READFILE) or die print "@[$myname] Can not close file called $pfile.\n";

  ## Update the attributes with the generated values
  for my $i ($gt_paramblock_start..$gt_paramblock_end) {
    if ($File[$i] =~ m/\.\w*/) { ## it match a word which starts with a dot
      my $param = $File[$i];
      $param =~ s/^\s*\.//;
      $param =~ s/\s*\(.*$//;
      chomp($param);
      if (exists $$params_ref{$param}) {
        $File[$i] =~ s/\(.*?\)/\($$params_ref{$param}\)/;
      } else {
        ## print "@[$myname] WARNING : Parameter $param does not exist in the generated GT instance!\n"
      }
    }
  }

  # Try to open file for write
  open(WRITEFILE, ">$pfile") or die print "@[$myname] Can not open file called $pfile for writing.\n";

  foreach my $line (@File){
    print WRITEFILE $line;
  }
  close(WRITEFILE) or die print "@[$myname] Can not close file called $pfile.\n";

  ## save the diff between the current and updated XCVR files
  my $file_name = $pfile;
  $file_name =~ s/^.*\///;
  $file_name =~ s/\.v$//;

  my $check_git = `git status`;
  if ($check_git =~ m/On branch/i) {
    system "git diff $pfile > $file_name.diff";
    system "git checkout -- $pfile";
  } else {
    print "WARNING: ADI's util_xcvr's can not be updated, because the current direcotry is NOT an HDL repository!\n";
  }

}
