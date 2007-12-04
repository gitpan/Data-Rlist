#
# Makefile.PL
#
# To install this module type the following:
#
#	$ perl Makefile.PL
#	$ make
#	$ make test
#	$ make install
#
# See also perlnewmod, perlmodinstall, h2xs.
#
#####
# $Writestamp: 2007-12-04 13:00:18 andreas$
# $Compile: make disttest$
# $Clean: make realclean$
#

use 5.006;
use ExtUtils::MakeMaker;

eval { require 5.6.0 } or die <<'EOD';
############
### This module requires lvaluable subroutines, which are not available
### in versions of Perl earlier than 5.6.  Please upgrade!
############
EOD

# Problem with Cygwin: Unable to find a perl 5 (by these names:
# /usr/bin/perl.exe perl.exe perl5.exe perl5.8.8.exe miniperl.exe, in these
# dirs: /cygdrive/h/bin /usr/local/bin /usr/bin /bin /usr/X11R6/bin ...
#
# MakeMaker then renders an unusable Makefile! Why? $^O is "cygwin" and "which
# perl" suggests "/usr/bin/perl".

print "perl thinks the current OS is '$^O'\n";

#system('pod2html lib/Data/Rlist.pm >Rlist.pm.html');

WriteMakefile(
	NAME			=> 'Data::Rlist',
	VERSION_FROM	=> 'lib/Data/Rlist.pm', # finds $VERSION
    PREREQ_PM       => { },					# e.g., Module::Name => 1.1
    ($] >= 5.005 ?				# Add these new keywords supported since 5.005
      (ABSTRACT_FROM=> 'lib/Data/Rlist.pm', # retrieve abstract from module
       AUTHOR       => 'Andreas Spindler <rlist@visualco.de>') : ()),

	clean => { FILES => ['*.tmp', 't/*.tmp'] },
#	dist => { TARFLAGS => 'cvfF', COMPRESS => 'gzip -9f', SUFFIX => '.gz' }
			 );
