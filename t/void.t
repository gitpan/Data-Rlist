#!/usr/bin/perl
#
# void.t
#
# Test reading/writinge non-existing files and empty data.
#
# $Writestamp: 2007-12-03 23:11:47 andreas$
# $Compile: perl -M'constant standalone => 1' void.t$

use warnings;
use strict;
use constant;
use Test;
BEGIN { plan tests => 13 }
BEGIN { unshift @INC, '../lib' if $constant::declared{'main::standalone'} }

use Data::Rlist qw/:options/;

our $tempfile = "$0.tmp";

#########################

{
	open my $fh, ">$tempfile"; close $fh;
	my $data = Data::Rlist::read($tempfile);

	ok(not defined $data);

	unlink($tempfile);
	$data = eval { Data::Rlist::read($tempfile) }; # trap die exception, get undef

	ok(not defined $data);

	#$Data::Rlist::DEBUG = 1;

	ok((not defined ReadData(\" ")) && Data::Rlist::missing_input()); # empty input
	ok((not defined ReadData(\";")) && Data::Rlist::missing_input()); # dto.
	ok((not defined ReadData(\",")) && Data::Rlist::missing_input()); # dto.

	ok(ref(ReadData(\"()")) =~ /ARRAY/);
	ok(ref(ReadData(\"{}")) =~ /HASH/);
	ok(!Data::Rlist::missing_input());

	ok(exists ReadData(\"\"\"")->{''});
	ok(exists ReadData(\"0")->{0});
	ok(exists ReadData(\"\"0\"")->{0});
	ok(exists ReadData(\"-x ")->{-x});
	ok(ReadData(\"x = 5;")->{x} == 5);

}

### Local Variables:
### buffer-file-coding-system: iso-latin-1
### End:
