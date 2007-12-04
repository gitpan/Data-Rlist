#!/usr/bin/perl
#
# deparse.t
#
# Use B::Deparse to deparse Rlist.pm, quote the whole text and let read it as
# Rlist.  Write as outlined text, which will use here-docs (heavy ones, in this
# case).
#
# BUGS DISCOVERED IN PERL
#
#	This is perl, v5.8.7 built for cygwin-thread-multi-64int
#	This is perl, v5.8.4 built for sun4-solaris
#
# Deparsing of \&Data::Rlist::lex fails:
#
#	Can't call method "name" on an undefined value at
#	/usr/local/lib/perl5/5.8.4/sun4-solaris/B/Deparse.pm line 948.
#
# $Writestamp: 2007-12-03 23:12:42 andreas$
# $Compile: perl -M'constant standalone => 1' deparse.t$

use warnings;
use strict;
use constant;
use Test;
BEGIN { plan tests => 3 }
BEGIN { unshift @INC, '../lib' if $constant::declared{'main::standalone'} }

use Data::Rlist qw/:options/;
use B::Deparse;

our $tempfile = "$0.tmp";

#########################

{
	no strict;
	my $deparser = B::Deparse->new(qw/-p -sC/);
	my %bodies = 
	map {
		my $fun = "Data::Rlist::$_";
		my $funref = eval { \&$fun };
		$fun => $deparser->coderef2text($funref)."\n" # add final newline so
                                                      # that string qualifies
                                                      # as here-doc
	}
	qw/new set get have require comptab compval escape unescape
	   open_input read write
	   compile compile1 compile2
	   compile_fast compile_fast1
	   compile_perl compile_Perl1
	   synthesize_pathname deep_compare/;

	ok(complete_options()->{here_docs}); # ...shall be enabled by default

	$Data::Rlist::MaxDepth = 10;
	my $obj = new Data::Rlist(-data => \%bodies,
							  -input => $tempfile, -output => $tempfile,
							  -options => 'default');
	ok($obj->write);
	ok(not CompareData(\%bodies, $obj->read));
}

### Local Variables:
### buffer-file-coding-system: iso-latin-1
### End:
