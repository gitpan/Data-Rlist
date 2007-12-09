#!/usr/bin/perl
# -*-cperl-*-

=head1 NAME

Data::Rlist - A lightweight data language for Perl, C and C++

=cut

# $Writestamp: 2007-12-10 00:09:53 andreas$
# $Compile: pod2html Rlist.pm >../../Rlist.pm.html$
# $Compile: podchecker Rlist.pm$

=head1 SYNOPSIS

    use Data::Rlist;

Data from files:

                  Data::Rlist::write($data, $filename);
    $data       = Data::Rlist::read($filename);
    $data       = ReadData($filename);

Data from text:

    $string_ref = Data::Rlist::write_string($data);
    $string     = Data::Rlist::make_string($data);
    $data       = Data::Rlist::read_string($string);
    $data       = ReadData(\$string);

Object-oriented interface:

    $object     = new Data::Rlist(-data => $thing, -output => \$target_string)

    $string_ref = $object->write; # compile $thing, return \$target_string

    use Env qw/HOME/;

    $object->set(-output => "$HOME/.foorc");

    $object->write(".barrc");   # the argument overrides -output
    $object->write;             # write "~/.foorc", return 1
    WriteData($object);         # dto.

The F<-input> attribute defines the text to be compiled into Perl data:

    $object->set(-input => \$input_string);

    $data       = $object->read;
    $data       = $object->read($other); # overrides -input

    $object->set(-input => "$HOME/.foorc");

    $data       = $object->read;                 # parse "~/.foorc"
    $data       = $object->read("$HOME/.barrc"); # override -input
    $data       = $object->read(\$string);       # parse $string
    $data       = $object->read_string($string_or_ref);
    $data       = ReadData($string_or_ref);

Make up a string out of thin air, no matter how F<-output> is set:

    $string_ref = $object->write_string; # write to new string (ignores -output)
    $string     = $object->make_string;  # dto. but return string value, not ref

    print $object->make_string; # dumps $thing
    PrintData($object);         # dto.
    PrintData($thing);          # dto.

Using F<Data::Rlist> one can also create deep-copies of Perl data:

    $reloaded   = Data::Rlist::keelhaul($thing);

    $object     = new Data::Rlist(-data => $thing);

    $reloaded   = $object->keelhaul;
    $reloaded   = KeelhaulData($object);

The functionality is called F<keelhauling>.  The metaphor vividly connotes that F<$thing> is
stringified, then compiled back.  See F<L</keelhaul>()> for why this only sounds useless.

The little brother of F<L</keelhaul>()> is F<L</deep_compare>()>:

    print join("\n", Data::Rlist::deep_compare($a, $b));

=head1 VENUE

F<Random-Lists> (Rlist) is a tag/value format to describe data structures as plain text.  Therefore
it defines lists of values (arrays) and tags/values (hashes). Basic values are constant strings and
numbers.  The format attempts to represent the data pure and untinged, but without breaking its
structure or legibility.  The language

- allows the definition of hierachical data,

- disallows recursively-defined data,

- does not consider user-defined types,

- defines no keywords, no variables and no arithmetic expressions,

- defines only constant data,

- uses 7-bit-ASCII character encoding.

Rlists are built from only four primitives: F<number>, F<string>, F<array> and F<hash>.  Like with
CSV the lexical overhead Rlist imposes is minimal: files are merely data.  They're processable by
scripts, and in text editors users see the pure data in a structured from, rather then getting
dazzled by language gizmo's.

With Rlist data is not typified, and hence data schemes are tacit consents between the users of the
data (the programs).  But schemes can be implemented by storing the meta information together with
the data itself.

=over

=item Numbers and Strings (Scalars)

Strings:

    "Hello, World!"

    <<hamlet
    "This above all: to thine own self be true". - (Act I, Scene III).
    hamlet

Symbols:

    foobar   cogito.ergo.sum   Memento::mori

Numbers:

    38   10e-6   -.7   3.141592653589793

Strings are wrapped by double-quotes.  Identifiers (or: symbolic names) are strings consisting only
of F<[a-zA-Z_0-9-/~:.@]> characters; for them the quotes are optional. Numbers adhere to the IEEE
754 syntax for integer- and floating-point numbers.  For details see F<L<is_symbol>()> and
F<L<is_number>()>.

=item Arrays and Hashes (Lists)

Arrays are sequential lists:

    ( 1, 2, ( 3, "Audiatur et altera pars!" ) )

Hashes are associative lists:

    {
        key = value;
        lonely-key;
        3.14159 = Pi;
        "Meta-syntactic names" = (foo, bar, "lorem ipsum", Acme, ___);
    }

=back

=head1 EXAMPLES

Single strings and numbers:

    "Hello, World!"

    foo                         # compiles to { 'foo' => undef }

    3.1415                      # compiles to { 3.1415 => undef }

Array:

    (1, a, 4, "b u z")          # list of numbers/strings

    ((1, 2),
     (3, 4))                    # list of list (4x4 matrix)

    ((1, a, 3, "foo bar"),
     (7, c, 0, ""))             # another list of lists

Array of strings:

    warning = (
        "main correlation-matrix not positive-definite", 
        "using pseudo-decomposed sigma-matrix", 
        "cannot evaluate CVaR: the no. of simulations is to low for confidence-level 0.90"
    );

Configuration object as hash:

    {
        contribution_quantile = 0.99;
        default_only_mode = Y;
        importance_sampling = N;
        num_runs = 10000;
        num_threads = 10;
        # etc.
    }

A comprehensive example:

    Metaphysic-terms =
    {
        Numbers =
        {
            3.141592653589793 = "The ratio of a circle's circumference to its diameter.";
            2.718281828459045 = <<___;
The mathematical constant "e" is the unique real number such that the value of
the derivative (slope of the tangent line) of f(x) = e^x at the point x = 0 is
exactly 1.
___
            42 = "The Answer to Life, the Universe, and Everything.";
        };

        Words =
        {
            ACME = <<Value;
A fancy-free Company [that] Makes Everything: Wile E. Coyote's supplier of equipment and gadgets.
Value
            <<Key = <<Value;
foo bar foobar
Key
[JARGON] A widely used meta-syntactic variable; see foo for etymology.  Probably
originally propagated through DECsystem manuals [...] in 1960s and early 1970s;
confirmed sightings go back to 1972. [...]
Value
        };
    };

=head1 DESCRIPTION

=head2 Audience

Rlist is useful as a "glue data language" between different systems and programs, for configuration
files and object serialization.  The format excels over comma-separated values (CSV), but isn't as
excessive as XML:

=over

=item *

Like CSV the format describes merely the data itself, but the data may be structured in multiple
levels, not just lines.

=item *

Like XML data can be as complex as required, but while XML is geared to markup data within some
continuous text (the document), Rlist defines the pure data structure.

=back

Portable implementations yet exist for Perl, C and C++. They're stable, efficient and do not depend
on other software.  The Perl implementation operates directly on builtin types, where C++ uses STL
types.  Either way data integrity is guaranteed: floats won't loose their precision, Perl strings
are loaded into F<std::string>s, and Perl hashes and arrays resurrect in as F<std::map>s and
F<std::vector>s.

The implementations scale well: a single text files can express hundreds of megabytes of data,
while the data is readable in constant time and with constant memory requirements.  This makes
files applicable as "mini-databases" loaded into RAM at program startup.  For example,
L<http://www.sternenfall.de> uses Rlist instead of a MySQL database.

=head2 Character Encoding

Rlist text uses 7-bit-ASCII.  The 95 printable character codes 32 to 126 occupy one character.
Codes 0 to 31 and 127 to 255 require four characters each: the F<\> escape character followed by
the octal code number. For example, the German Umlaut character F<E<uuml>> (252) is translated into
F<\374>.  An exception are the following codes:

	ASCII				ESCAPED AS
	-----				----------
      9 tab				  \t
     10 linefeed		  \n
     13 return  		  \r
	 34 quote	  "		  \"
	 39 quote	  '		  \'
	 92 backslash \		  \\

=head2 Values

Rlist F<values> are either scalars, array elements or the value of a pair. They're always constant.

=head3 Scalar Values

All program data is finally convertible into numbers and strings.  In Rlist number and string
constants follow the C language lexicography.  Strings that look like C identifier names must not
be quoted.

Strings are quoted implicitly when building Rlists; when reading them back strings are unquoted.
Quoting means to encode characters according to the input character set (see above), then to
double-quote the result.

=head3 Default Values

By definition all input is compiled into an array or hash; hashes are the default. For example, the
string C<"Hello, World!"> is compiled into:

    { "Hello, World!" => undef }

Likewise the parser of the C++ implementation by default returns a F<std::map> with one pair. The
default scalar value is the empty string C<"">. In Perl, F<undef>'d list elements are compiled into
C<"">.

=head3 Here-Documents

Rlist is capable of a line-oriented form of quoting based on the UNIX shell F<here-document> syntax
and RFC 111.  Multi-line quoted strings can be expressed with

    <<DELIMITER

Following the sigil F< << > an identifier specifies how to terminate the string scalar.  The value
of the scalar will be all lines following the current line down to the line starting with the
delimiter.  There must be no space between the F< << > and the identifier.  For example,

    {
        var = {
            log = {
                messages = <<LOG;
    Nov 27 21:55:04 localhost kernel: TSC appears to be running slowly. Marking it as unstable
    Nov 27 22:34:27 localhost kernel: Uniform CD-ROM driver Revision: 3.20
    Nov 27 22:34:27 localhost kernel: Loading iSCSI transport class v2.0-724.<6>PNP: No PS/2 controller found. Probing ports directly.
    Nov 27 22:34:27 localhost kernel: wifi0: Atheros 5212: mem=0x26000000, irq=11
    LOG
            };
        };
    }

=head3 Binary Data

Binary data shall be represented as base64-encoded string, or L<here-document|/Here-Documents>
string.  For example,

    use MIME::Base64;

    $str = encode_base64($binary_buf);

The returned encoded string F<$str> is broken into lines of no more than 76 characters each and it
will end with C<"\n"> unless it is empty.  Since F<$str> ends with C<"\n"> it qualifies as
here-document.  See also L<Encode>, L<MIME::Base64>.

B<EXAMPLE>

	use Data::Rlist;
	use MIME::Base64;

    $binary_data = join('', map { chr(int rand 256) } 1..300);
	$sample = { random_string => encode_base64($binary_data) };

	WriteData $sample, 'random.rls', 'default';

Writes a file F<random.rls> that looks like:

	{
		random_string = <<___
	w5BFJIB3UxX/NVQkpKkCxEulDJ0ZR3ku1dBw9iPu2UVNIr71Y0qsL4WxvR/rN8VgswNDygI0xelb
	aK3FytOrFg6c1EgaOtEudmUdCfGamjsRNHE2s5RiY0ZiaC5E5XCm9H087dAjUHPtOiZEpZVt3wAc
	KfoV97kETH3BU8/bFGOqscCIVLUwD9NIIBWtAw6m4evm42kNhDdQKA3dNXvhbI260pUzwXiLYg8q
	MDO8rSdcpL4Lm+tYikKrgCih9UxpWbfus+yHWIoKo/6tW4KFoufGFf3zcgnurYSSG2KRLKkmyEa+
	s19vvUNmjOH0j1Ph0ZTi2pFucIhok4krJi0B5yNbQStQaq23v7sTqNom/xdRgAITROUIoel5sQIn
	CqxenNM/M4uiUBV9OhyP
	___
	;
	}

Each line accept the last line in the here-doc has 75 characters, plus the newline.  Note that from
the predefined-compile options only C<"default"> and C<"outlined"> enable here-docs.

=head3 Embedded Perl Code

Rlists may define embedded programs: F<nanonscripts>.  They're defined as
L<here-document|/Here-Documents> that is delimited with the special delimiter C<"perl">.  For
example,

    hello = (<<perl);
    print "Hello, World!";
    perl

After the text has been fully parsed such strings are F<eval>'d in the order of their occurrence.
Within the F<eval> F<%root> or F<@root> defines the root of the current Rlist.

=head2 Comments

Rlist supports multiple forms of comments: F<//> or F<#> single-line-comments, and F</* */>
multi-line-comments.

=head2 Compile Options

The format of the compiled text and the behavior of F<L</compile>()> can be controlled by the
OPTIONS parameter of F<L</write>()>, F<L</write_string>()> etc.  The argument is a hash defining how
the Rlist text shall be formatted. The following pairs are recognized:

=over

=item 'precision' =E<gt> PLACES

Make F<L</compile>()> round all numbers to PLACES decimal places, by calling F<L</round>()> on each
scalar that L<looks like a number|/is_number>.  By default PLACES is F<undef>, which means floats
are not rounded.

=item 'scientific' =E<gt> FLAG

Causes F<L</compile>()> to masquerade F<$Data::Rlist::RoundScientific>.  See F<L</round>()>.

=item 'code_refs' =E<gt> TOKEN

Specifiy how F<L</compile>()> shall treat F<CODE> reference.  Legal values for TOKEN are 0 (the
default), C<"call"> and C<"deparse">.

0 compiles the reference into the string C<"?CODE?">. C<"call"> calls the code, then compiles the
return value.  C<"deparse"> serializes the code using F<B::Deparse>, which reproduces the Perl
source. Note that it then makes sense to enable C<"here_docs"> (see below), because otherwise the
deparsed code will be in one string with LFs quoted as C<"\n">.

=item 'threads' =E<gt> COUNT

If enabled F<L</compile>()> internally use multiple threads.  Note that this makes only sense on
machines with at least COUNT CPUs.

=item 'here_docs' =E<gt> FLAG

If enabled strings with at least two newlines in them are written as
L<here-document|/Here-Documents>, when possible.  Note that the string has to be terminated with a
C<"\n"> to qualify as here-document.

=item 'auto_quote' =E<gt> FLAG

When true do not quote strings that look like identifiers (by means of F<L<is_symbol>()>), otherwise
quote F<all> strings.  Note that hash keys are not affected by this flag.  The default is true, but
not for F<L<write_csv>()> and F<L<write_conf>()>, where the default is false (quote all
non-numbers).

=item 'outline_data' =E<gt> NUMBER

Use C<"eol_space"> (linefeed) to "distribute data on many lines."  Insert a linefeed after every
NUMBERth array value; 0 disables outlining.

=item 'outline_hashes' =E<gt> FLAG

If enabled, and C<"outline_data"> is also enabled, prints F<{> and F<}> on distinct lines when
compiling Perl hashes with at least one pair.

=item 'separator' =E<gt> STRING

The comma-separator string to be used by F<L</write_csv>()>.  The default is C<','>.

=item 'delimiter' =E<gt> REGEX

Field-delimiter for F<L</read_csv>()>.  There is no default value.  To read configuration files,
for example, you may use C<'\s*=\s*'> or C<'\s+'>; and to read CSV-files you may use
C<'\s*[,;]\s*'>.

=back

The following options format the generated Rlist; normally you don't want to modify them:

=over

=item 'bol_tabs' =E<gt> COUNT

Count of physical, horizontal TAB characters to use at the begin-of-line per indentation
level. Defaults to 1. Note that we don't use blanks, because they blow up the size of generated
text without measure.

=item 'eol_space' =E<gt> STRING

End-of-line string to use (the linefeed).  For example, legal values are C<"">, C<" ">, C<"\r\n">
etc. The default is C<"\n">.

=item 'paren_space' =E<gt> STRING

String to write after F<(> and F<{>, and before F<}> and F<)> when compiling arrays and hashes.

=item 'comma_punct' =E<gt> STRING

=item 'semicolon_punct' =E<gt> STRING

Comma and semicolon strings, which shall be at least C<","> and C<";">.  No matter what,
F<L</compile>()> will always print the C<"eol_space"> string after the C<"semicolon_punct"> string.

=item 'assign_punct' =E<gt> STRING

String to make up key/value-pairs. Defaults to C<" = ">.  Note the this is a compile option: the
parser always expects some C<"="> to designate a pair.

=back

=head3 Predefined Options

The L<OPTIONS|/Compile Options> parameter accepted by some package functions is either a hash-ref or the name of a
predefined set:

=over

=item 'default'

Default if writing to a file.

=item 'string'

Compact, no newlines/here-docs. Renders a "string of data".

=item 'outlined'

Optimize the compiled Rlist for maximum readability.

=item 'squeezed'

Very compact, no whitespace at all. For very large Rlists.

=item 'perl'

Compile data in Perl syntax, using F<L</compile_Perl>()>, not F<L</compile>()>.  The output then
can be F<eval>'d, but it cannot be F<L</read>()> back.

=item 'fast' or F<undef>

Compile data as fast as possible, using F<L<compile_fast>()>, not F<L</compile>()>.

=back

All functions that define an L<OPTIONS|/Compile Options> parameter implicitly call
F<L</complete_options>()> to complete the argument from one of the predefined sets, and
C<"default">.  Therefore you may just define a "lazy subset of options" to these functions. For
example,

    my $obj = new Data::Rlist(-data => $thing);

    $obj->write('thing.rls', { scientific => 1, precision => 8 });

=head2 Debugging Data (Finding Self-References)

Debugging (hierachical) data means breaking recursively-defined data.

Set F<$Data::Rlist::MaxDepth> to an integer above 0 to define the depth under which
F<L</compile>()> shall not venture deeper. 0 disables debugging.  When positive compilation breaks
on deep recursions caused by circular references, and on F<stderr> a message like the following is
printed:

    ERROR: compile2() broken in deep ARRAY(0x101aaeec) (depth = 101, max-depth = 100)

The message will also be repeated as comment when the compiled Rlist is written to a file.
Furthermore F<$Data::Rlist::Broken> is incremented by one - and compilation continues!  So, any
attempt to venture deeper as suggested by F<$Data::Rlist::MaxDepth> in the data will be blocked,
but compilation continues above that depth.  Please see F<L</broken>()>.

=cut

package Data::Rlist;

use strict;
use warnings;
use Exporter;
use Carp;
use Scalar::Util qw/reftype/;
use integer;

use vars qw/$VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS

            %PredefinedOptions $DEBUG 
            $RoundScientific $SafeCppMode 
            $R $Fh $Locked $DefaultMaxDepth $MaxDepth $Depth
            $Errors $Broken $MissingInput
            $DefaultCsvDelimiter $DefaultConfDelimiter $DefaultConfSeparator

            $g_re_punct_cset $g_re_integer_here $g_re_float_here
            $g_re_symbol_cset $g_re_symbol_here $g_re_string_here
            $g_re_integer $g_re_float
			$g_re_symbol $g_re_string $g_re_value
		   /;

use vars qw/$Readstruct $ReadFh $C1 $Ln $LnArray/; # used by open, lex

use constant DEFAULT => qq'""'; # default Rlist, the empty string

BEGIN {
    $VERSION = '1.38';
    $DEBUG = 0;
    @ISA = qw/Exporter/;

    # Always exported (:DEFAULT) when the package is fetched with "use", not "required".

    @EXPORT = qw/ReadCSV WriteCSV
                 ReadConf WriteConf
                 ReadData WriteData
                 PrintData OutlineData StringizeData SqueezeData
                 KeelhaulData CompareData/;

    # Symbols exported on request.

    @EXPORT_OK = qw/:DEFAULT

                    predefined_options complete_options

                    maybe_quote quote escape unquote unescape unhere
                    is_value is_random_text is_symbol is_integer is_number
                    split_quoted parse_quoted

                    equal round

                    keelhaul deep_compare fork_and_wait synthesize_pathname

                    $g_re_integer $g_re_float $g_re_symbol/;

    %EXPORT_TAGS = (# Handle IEEE numbers
                    floats => [@EXPORT, qw/equal round is_number is_integer/],
                    # Handle (quoted) strings
                    strings => [@EXPORT, qw/maybe_quote quote escape
                                            unquote unescape unhere
                                            is_value is_random_text is_number is_integer is_symbol
                                            split_quoted parse_quoted/],
                    # Compile options
                    options => [@EXPORT, qw/predefined_options complete_options/],
                    # Auxiliary functions
                    aux => [@EXPORT, qw/keelhaul deep_compare fork_and_wait synthesize_pathname/]);

    $MaxDepth = 0; $DefaultMaxDepth = 100; $Broken = 0;
    $SafeCppMode = 1;
    $RoundScientific = 0;
    $DefaultConfSeparator = ' = ';
    $DefaultConfDelimiter = '\s*=\s*';
    $DefaultCsvDelimiter = '\s*,\s*';

    %PredefinedOptions =
    (
     default =>
     {
      # Warning: "code_refs" are disabled by default because compile_fast() (the default compile
      # function) never calls subs.  Likewise the default "precision" must be undef!
      eol_space => "\n",
      bol_tabs => 1,
      outline_hashes => 0,
      outline_data => 6,
      paren_space => '',
      comma_punct => ', ',
      semicolon_punct => ';',
      assign_punct => ' = ',
      here_docs => 1,
      auto_quote => undef,      # let write() and write_csv() choose their defaults
      code_refs => 0,
      scientific => 0,
      separator => ',',
      delimiter => undef,
      precision => undef
     },

     string =>
     {
      eol_space => '',
      bol_tabs => 0,
      outline_data => 0,
      here_docs => 0
     },

     outlined =>
     {
      eol_space => "\n",
      bol_tabs => 1,
      outline_hashes => 1,
      outline_data => 1,
      paren_space => ' ',
      comma_punct => ', ',
     },

     squeezed =>
     {
      bol_tabs => 0,
      eol_space => '',
      outline_hashes => 0,
      outline_data => 0,
      here_docs => 0,
      code_refs => 0,
      paren_space => '',
      comma_punct => ',',
      assign_punct => '=',
      precision => 6,
     }
    );

    ########
    # Initialize global regular expressions.
    #
    # Note that $g_re_symbol_here shall be defined equal to 'identifier' regex in 'rlist.l'.
    # Otherwise the C/C++ and Perl implementations might not be compatible.  See also the C++
    # function rlist::quote() and the {identifier} rule in rlist.l
	#
	# By default, the "^" character is guaranteed to match only the beginning of the string, the
	# "$" character only the end (or before the newline at the end). The "/s" modifier will force
	# "^" to match only at the beginning of the string and "$" to match only at the end (or just
	# before a newline at the end) of the string.  "$" hence ignores an optional trailing newline.
	#
	# When "/m" is used this means for "foo\nbar" the "$" matches the end of the string (after "r")
	# and also before every line break (between "o" and "\n").  Therefore we've to use "\z" which
	# matches only at the end of the string.
	#
	# See also <http://www.regular-expressions.info/examplesprogrammer.html>.
	#

    $g_re_integer_here = '[+-]?\d+';
    $g_re_float_here = '(?:[+-]?)(?=\d|\.\d)\d*(?:\.\d*)?(?:[Ee](?:[+-]?\d+))?';
    $g_re_punct_cset = '\=\,;\{\}\(\)';
    $g_re_symbol_cset = 'a-zA-Z_0-9\-/\~:\.@';
    $g_re_symbol_here = '[a-zA-Z_\-/\~:@]'.qq'[$g_re_symbol_cset]*';
	$g_re_string_here = '"[^"\\\r\n]*(?:\\.[^"\\\r\n]*)*"'; # " allowed inside the quotes, but only as \"

    $g_re_integer = qr/^$g_re_integer_here\z/;
    $g_re_float = qr/^$g_re_float_here\z/;
    $g_re_symbol = qr/^$g_re_symbol_here\z/;
	$g_re_string = qr/^$g_re_string_here\z/;

	# Compiled Rlist value that can be parsed back.
	# Note that $g_re_string is nearly equally as fast as '^"'.
    $g_re_value = qr/$g_re_string|
					 $g_re_integer|
					 $g_re_float|
					 $g_re_symbol/x;

    $g_re_value = qr/^$g_re_string_here\z|
					 ^$g_re_integer_here\z|
					 ^$g_re_float_here\z|
					 ^$g_re_symbol_here\z/x if 0; # slightly slower; why?

    ########
    # Rlist parser-map.
    #
    #   token => [ rule, deduce-function ]
    #   rule  => [ rule, deduce-function ]
    #
    # See `lex()' function for token meanings.
	#

    use vars qw/%Rules @VStk $rule_min $rule_max
                $pv $pv1 $pv2 $pk $pk1 $pk2 $pl $ph1 $ph2/;

    %Rules =
    (
     'v;' => [ 'h', sub {
                   $pk = pop @VStk;
                   if (ref $pk) {
                       push @VStk, $pk;
                   } else { 
                       # no checking of $pk against ""
                       push @VStk, { $pk => '' }
                   }
               }
             ],

     'v=v;' => [ 'h', sub {
                     ($pv, $pk) = (pop @VStk, pop @VStk);
                     push @VStk, { $pk => $pv };
                 }
               ],

     'v,v'  => [ 'l', sub {
                     ($pv2, $pv1) = (pop @VStk, pop @VStk);
                     push @VStk, [ $pv1, $pv2 ];
                 }
               ],

     'l,v'  => [ 'l', sub {
                     $pv = pop @VStk; # pop the item
                     push @{$VStk[$#VStk]}, $pv; # push to list
                 }
               ],

     '(v)'  => [ 'v', sub {
                     $pv = pop @VStk; push @VStk, [ $pv ];
                 }
               ],

     '(v,)' => [ 'v', sub { 
                     $pv = pop @VStk; push @VStk, [ $pv ];
                 }
               ],

     'hh' => [ 'h', sub {
                   # Intermediate rule to merge two hashes created by "v=v;", "v;" or "hh".  The
                   # 2nd should consist only of one pair.

                   ($ph2) = pop @VStk;
                   ($pk, $pv) = %$ph2;
                   $VStk[$#VStk]->{$pk} = $pv; # reuse (reload) the 1st hash
                 }
             ],

     '(l)'  => [ 'v', sub { } ],
     '(l,)' => [ 'v', sub { } ],
     '{h}'  => [ 'v', sub { } ],

     '()'   => [ 'v', sub { push @VStk, [] } ],
     '{}'   => [ 'v', sub { push @VStk, {} } ],
    );                          # TODO: let all return undef; maybe faster?

    # Add rules for syntax errors.  The error-recovering rule '??' does not try to recover from the
    # error - it simply removes the snarly tokens and continues onward EOF.

    my %err_rules =
    (
     '??' => [ '', sub {
                   $Readstruct->{lerr} =~ s/\s/ /go;
                   pr1nt('ERROR', ('syntax error', $Readstruct->{lerr}));
                   $Errors++;
               }
             ],

     'vv' => [ '??', sub { 
                   my($a, $b) = (pop(@VStk), pop(@VStk));
                   $Readstruct->{lerr} = q(missing ',' or ';' between ).qq'"$a"'.' and '.qq'"$b"'
               }
             ],

     'lv' => [ 'l,v', sub {
                   $pv = pop @VStk;
                   pr1nt('WARNING', q("missing ',' in list: ").$pv.q("));
                   push @VStk, $pv;
               }
             ],

     'v=v}' => [ 'h}', sub {
                     ($pv, $pk) = (pop @VStk, pop @VStk);
                     pr1nt('WARNING', q(unterminated pair: ").$pk.q("));
                     push @VStk, { $pk => $pv }
                 }
               ],

     'v=v,' => [ '??', sub {
                     pop @VStk; pop @VStk;
                     $Readstruct->{lerr} = q(key/value pair terminated with ',' (use ';'));
                 }
               ],

     '(v}' => [ '??', sub {
                    pop @VStk;
                    $Readstruct->{lerr} = "')' expected"
                }
              ],

     '{v}' => [ 'h', sub { 
                    $pv = pop @VStk; 
                    push @VStk, { $pv => '' }
                }
              ],
     '{v)' => [ '??', sub {
                    pop @VStk;
                    $Readstruct->{lerr} = "'}' expected"
                }
              ],
    );

    foreach my $rule ((',,', '{{', '{(', '{=', '(,', 'v=;', 'v=,', 'v=}', 'v=)'))
    {
        $err_rules{$rule} =
        [ '??', 
          sub {
              my @r = map { "'$_'" } map {
                  $_ eq 'v' ? pop(@VStk) : $_ } split(/ */, $rule);
              $Readstruct->{lerr} = join(' ', @r)
          }
        ];
    }

    if (1) {
        while (my($rule, $def) = each %err_rules) {
            die $rule if exists $Rules{$rule};
            $Rules{$rule} = $def;
        }
    }

    $rule_max = 0; $rule_min = 9;
    foreach (keys %Rules) {
        $rule_min = length($_) if length($_) < $rule_min;
        $rule_max = length($_) if length($_) > $rule_max;
    }
    die if $rule_min != 2;
    die if $rule_max != 4;
}

sub pr1nt(@)
{
    # This function is used to write a new comment line (usually some sort of error message) into
    # the currently compiled file, and to STDERR (if $Data::Rlist::DEBUG).

    my $label = shift;
    foreach my $fh (grep { defined } ($Fh, $DEBUG ? *STDERR{IO} : undef)) {
        next unless defined $fh;
        print $fh "\n", map { $fh == defined($Fh) ? "# $_" : $_ }
        join(': ', grep { length }
             ($label,
              ((defined($Readstruct) && exists $Readstruct->{filename}) ? $Readstruct->{filename}."($.)" : ""),
              grep { defined } @_));
    }
}

=head1 PACKAGE FUNCTIONS

=head2 Construction

=head3 F<new()> and F<dock()>

The core functions to cultivate package objects are F<new()>, F<L</set>()> and F<L</get>()>.

F<new()> allocates a F<Data::Rlist> object, accepting values peculiar to the new object.  These
F<attributes> will be implicitly used in place of arguments that are normally passed to package
functions - when these functions are called in the context of an object. The following functions
may be called also as F<instance methods>:

    read()              write()
    read_string()       write_string()
    read_csv()          write_csv()
    read_conf()         write_conf()
    keelhaul()

When ennobled to methods these functions load their arguments from synonymous attributes of the
object.  As usual the object is defined by the first argument.  Other arguments are optional, but
when specified they have precedence over attributes.  Note, however, that unless these functions
are called as methods their first argument has an indifferent meaning.  For example, F<L</read>()>
excepts an input file or string as the first argument, F<L</write>()> the data to compile etc.

F<L</dock>()> is used to exclusively link some object to the package, which means that some package
globals are temporarily set from its attributes.  Each function that is called as method uses
F<dock()> to localize globals and hence to lock the package.

=over 4

=item F<new(ATTRIBUTES)>

Create a F<Data::Rlist> object from ATTRIBUTES, a hash-table. For example,

    $self = Data::Rlist->new(-input => 'this.dat',
                             -data => $thing,
                             -output => 'that.dat');

creates an object for which the call F<$self-E<gt>read()> reads from F<this.dat>, and
F<$self-E<gt>write()> writes F<$thing> to F<that.dat>.

B<PARAMETERS>

=over 8

=item -input =E<gt> INPUT

=item -filter =E<gt> FILTER

=item -filter_args =E<gt> FILTER-ARGS

Defines what to parse. INPUT shall be a filename or string reference.  FILTER and FILTER-ARGS
define how to preprocess an input file.  FILTER can be 1 to select the standard C preprocessor
F<cpp>.  These attributes are applied by F<L</read>()>, F<L</read_string>()>, F<L<read_conf>()> and
F<L</read_csv>()>.

=item -data =E<gt> DATA

=item -output =E<gt> OUTPUT

=item -options =E<gt> OPTIONS

=item -header =E<gt> HEADER

DATA defines the Perl data to be L<compiled|/compile> into text. OPTIONS defines L<how the text
shall be compiled|/Compile Options>, and OUTPUT where to put it.  HEADER defines the comments: an
array of text lines, each of which will by prefixed by a F<#> and then written at the top of the
output file.  These attributes are applied by F<L</write>()>, F<L</write_string>()>,
F<L</write_conf>()>, F<L</write_csv>()> and F<L</keelhaul>()>.

=item -delimiter =E<gt> DELIMITER

Defines the field delimiter for F<.csv>-files. Applied by F<L</read_csv>()> and F<L</read_conf>()>.

=item -columns =E<gt> STRINGS

Defines the column names for F<.csv>-files that, when available, are written into the first line.
Applied by F<L</write_csv>()> and F<L</write_conf>()>.

=back

B<ATTRIBUTES THAT MASQUERADE PACKAGE GLOBALS>

These attributes raise new values for package globals while instance methods are executed.  You
will notice that some globals can also be set by the L<compile options|/Compile Options>.  But
while these options are anonymuous hash-tables, possible shared by many objects, the below
attributes define such options F<per object>.  This means they're charged each time a function is
called as an instance method.  (To afford this the method internally calls F<L</dock>()>.)

For example, when F<$Data::Rlist::RoundScientific> is true F<Data::Rlist::L</round>()> formats the
number in either normal or exponential (scientific) notation, whichever is more appropriate for its
magnitude.  F<round()> is called during compilation when the C<"precision"> option is defined, in
order to round all numbers to a certain count of decimal places.  By setting F<-RoundScientific>
this sort of formatting can be enabled per object, not per package.

=over

=item -MaxDepth =E<gt> INTEGER

=item -SafeCppMode =E<gt> FLAG

=item -RoundScientific =E<gt> FLAG

Masquerades F<$Data::Rlist::MaxDepth>, F<$Data::Rlist::SafeCppMode> and
F<$Data::Rlist::RoundScientific>.

=item -DefaultCsvDelimiter =E<gt> REGEX

=item -DefaultConfDelimiter =E<gt> REGEX

Masquerades F<$Data::Rlist::DefaultCsvDelimiter> (for F<L</read_csv>()>) and
F<$Data::Rlist::DefaultConfDelimiter> (for F<L</read_conf>()>).  These globals define the default
regexes to use when the F<-options> attribute does not specifiy L<the C<"delimiter"> regex|/Compile
Options>.

=item -DefaultConfSeparator =E<gt> STRING

F<L</write_conf>()> uses this attribute to masquerade F<$Data::Rlist::DefaultConfSeparator>, the
default string to use when the F<-options> attribute does not specifiy 
L<the C<"separator"> string|/Compile Options>.

=back

=item F<dock(SELF, SUB)>

Wire some flittering object SELF back to the package that incubated it (this one).  

F<dock()> saves some package globals and sets their new values based on SELF's attributes. Then it
calls SUB (a code-reference) in the realm of the new globals. After SUB returned it restores the
globals and returns what SUB had returned.

While SUB runs, the package is dedicated to SELF and hence locked (F<$Data::Rlist::Locked> is
true).

The saved globals are:

    $Data::Rlist::MaxDepth
    $Data::Rlist::SafeCppMode
    $Data::Rlist::RoundScientific
    $Data::Rlist::DefaultCsvDelimiter,
    $Data::Rlist::DefaultConfDelimiter
    $Data::Rlist::DefaultConfSeparator



=back

=head3 F<set()> and F<get()>

=over

=item F<set(SELF[, ATTRIBUTE]...)>

Reset or initialize object attributes, then return SELF.  Each ATTRIBUTE is a name/value-pair.  See
F<L</new>()> for a list of valid names.  For example,

    $obj->set(-input => \$str, -output => 'temp.rls', -options => 'squeezed');

=item F<get(SELF, NAME[, DEFAULT])>

=item F<require(SELF[, NAME])>

=item F<has(SELF[, NAME])>

Get some attribute NAME from object SELF.  Unless NAME exists returns DEFAULT.  The F<require()>
method has no default value, hence it dies unless NAME exists. F<has()> returns true when NAME
exists, false otherwise.  For NAME the leading hyphen is optional.  For example,

    $self->get('foo');          # returns $self->{-foo} or undef
    $self->get(-foo=>);         # dto.
    $self->get('foo', 42);      # returns $self->{-foo} or, unless exists, 42

=back

=cut

sub new {
    my($prototype, $k) = shift;
    carp <<___ if @_ & 1;
$prototype->Data::Rlist::new(${\(join(', ', @_))})
    odd number of arguments supplied, expecting key/value pairs
___
    my %args = @_;
    bless { map { $k = $_;
                  s/^_+//o;     # allow leading underscores
                  s/^([^\-])/-$1/o; # prepend missing '-'
                  $_ => $args{$k}
              } keys %args }, ref($prototype) || $prototype;
}

sub set {
    my($self) = shift;
    my %attr = @_;
    while(my($k, $v) = each %attr) {
        $self->{$k} = $v
    } $self
}

sub require($$) {               # get attribute or confess
    my($self, $attr) = @_;
    my $v = $self->get($attr);
    carp "$self->get(): missing '$attr' attribute" unless defined $v;
    return $v;
}

sub get($$;$) {                 # get attribute or return default value/undef
    my($self, $attr, $default) = @_;
    $attr = '-'.$attr unless $attr =~ /^-/;
    return $self->{$attr} if exists $self->{$attr};
    return $default;
}

sub has($$) {
    my($self, $attr) = @_;
    $attr = '-'.$attr unless $attr =~ /^-/;
    exists $self->{$attr};
}

sub dock($\&) {
    my ($self, $block) = @_;
    carp "package Data::Rlist locked" if $Locked++;
    local $MaxDepth = $self->get(-MaxDepth=>) if $self->has(-MaxDepth=>);
    local $SafeCppMode = $self->get(-SafeCppMode=>) if $self->has(-SafeCppMode=>);
    local $RoundScientific = $self->get(-RoundScientific=>) if $self->has(-RoundScientific=>);
    local $DefaultCsvDelimiter = $self->get(-DefaultCsvDelimiter=>) if $self->has(-DefaultCsvDelimiter=>);
    local $DefaultConfDelimiter = $self->get(-DefaultConfDelimiter=>) if $self->has(-DefaultConfDelimiter=>);
    local $DefaultConfSeparator = $self->get(-DefaultConfSeparator=>) if $self->has(-DefaultConfSeparator=>);
    if (wantarray) {
        my @r = $block->(); $Locked--; return @r;
    } else {
        my $r = $block->(); $Locked--; return $r;
    }
}

=head2 Interface

This section lists the public functions to be called by users of the package.  These can be either
called as package functions or instance methods.

=head3 F<read()>, F<read_string()>, F<read_csv()> and F<read_conf()>

=over

=item F<read(INPUT[, FILTER, FILTER-ARGS])>

Parse data from INPUT, which specifies some Rlist-text.  See also F<L</errors>()>, F<L</write>()>.

B<PARAMETERS>

INPUT shall be either

- some Rlist object created by F<L</new>()>,

- a string reference, in which case F<read()> and F<L</read_string>()> parse Rlist text from it,

- a string scalar, in which case F<read()> assumes a file to parse.

See F<L</open_input>()> for the FILTER and FILTER-ARGS parameters, which are used to preprocess an
input file.  When an input file cannot be F<open>'d and F<flock>'d this function dies.  When INPUT
is an object you specify FILTER and FILTER-ARGS to overload the F<-filter> and F<-filter_args>
attributes.

B<RESULT>

F<L</read>()> returns the parsed data as array- or hash-reference, or F<undef> if there was no
data. The latter may also be the case when file consist only of comments/whitespace.

B<NOTES>

This function may die.  Dying is Perl's mechanism to raise exceptions, which can be catched with
F<eval>. For example,

    my $host = eval { use Sys::Hostname; hostname; } || 'some unknown machine';

This code fragment traps the F<die> exception: when it raised F<eval> returns F<undef>, otherwise
the result of calling F<hostname>. For F<read()> this means

    $data = eval { Data::Rlist::read($tempfile) };
    unless (defined $data) {
        print STDERR "$tempfile not found, is locked or is empty" 
    } else {
        # use $data
            .
            .
    }

=item F<read_csv(INPUT[, OPTIONS, FILTER, FILTER-ARGS])>

=item F<read_conf(INPUT[, OPTIONS, FILTER, FILTER-ARGS])>

Parse data from INPUT, which specifies some comma-separated-values (CSV) text.  Both functions

- read data from strings or files,

- use an optional delimiter,

- ignore delimiters in quoted strings,

- ignore empty lines,

- ignore lines begun with F<#> as comments.

F<read_conf()> is a variant of F<read_csv()> dedicated to configuration files. Such files consist
of lines of the form

    key = value

That is, F<read_conf()> simply uses a default delimiter of C<'\s*=\s*'>, while F<read_csv()> uses
C<'\s*,\s*'>.  Hence F<read_csv()> can be used as well for configuration files. For example, a
delimiter of C<'\s+'> splits the line at horizontal whitespace into multiple values (but, of
course, not within quoted strings).

See also F<L</ReadCSV>()>, F<L</ReadConf>()>, F<L</write_csv>()> and F<L</write_conf>()>.

B<PARAMETERS>

=over

=item INPUT

Please see F<L</read>()>.

=item FILTER, FILTER-ARGS

Please see F<L</open_input>()>.

=item OPTIONS

The actual difference between F<read_conf()> and F<read_csv()> is the default value for L<the
C<"delimiter"> regex|/Compile Options> in OPTIONS:

    FUNCTION    DELIMITER
    read_csv()  '\s*,\s*'
    read_conf() '\s*=\s*'

Note that the above defaults are actually defined by the package-globals
F<$Data::Rlist::DefaultCsvDelimiter> and F<$Data::Rlist::DefaultConfDelimiter>.

=back

B<RESULT>

Both functions return a list of lists.  Each embedded array defines the fields in a line, and may
be of variable length.

B<EXAMPLES>

Un/qouting of values happens implicitly.  Given a file F<db.conf>

    # Comment
    SERVER      = hostname
    DATABASE    = database_name
    LOGIN       = "user,password"

the call

    $opts = Data::Rlist::read_conf('db.conf');

returns (as F<$opts>)

    [
        [ 'SERVER', 'hostname' ],
        [ 'DATABASE', 'database_name' ],
        [ 'LOGIN', 'user,password' ]
    ]

To convert such an array into a hash C<%conf>, use

    %conf = map { @$_ } @{ReadConf 'db.conf'};

The F<L<write_conf>()> function can be used to update F<db.conf> from F<$opts>, so that

    push @$opts, [ 'MAGIC VALUE' => 3.14_15 ];

    Data::Rlist::write_conf('db.conf', { precision => 2 });

yields

    SERVER = hostname
    DATABASE = database_name
    LOGIN = "user,password"
    "MAGIC VALUE" = 3.14

=item F<read_string(INPUT)>

Calls F<L</read>()> to parse Rlist language productions from the string or string-reference INPUT.
INPUT may be an object-reference, in which case F<read_string()> attempts to parse the
string-reference defined by the F<-input> attribute.

=back

=head3 F<errors()>, F<broken()> and F<missing_input()>

=over

=item F<errors([SELF])>

Returns the number of syntax errors that occurred in the last call to F<L</parse>()>.  When called
as method (under SELF) returns the number of syntax errors that occured the last time SELF had
called F<L</read>()>.

=item F<broken([SELF])>

Returns the number of times the last F<L</compile>()> crossed the zenith of
F<$Data::Rlist::MaxDepth>. When called as method returns the information for the last time SELF had
called F<L</read>()>.

=item F<missing_input([SELF])>

Returns true when the last call to F<L</parse>()> yielded F<undef> because there was nothing to
parse.  (This means F<parse()> hadn't returned F<undef> because of syntax errors.)  When called as
method returns the information for the last time SELF had called F<L</read>()>.

=back

=cut

sub is_integer(\$);
sub is_number(\$);
sub is_symbol(\$);
sub is_random_text(\$);

sub read($;$$);
sub read($;$$) {
    my($input, $fcmd, $fcmdargs) = @_;

    if (ref($input) eq __PACKAGE__) {
        # $input is an object created by Data::Rlist::new
        $input->dock
        (sub {
             unless ($fcmd) {
                 $fcmd = $input->get('-filter');
                 $fcmdargs = $input->get('-filter_args');
             }
             my $ref = Data::Rlist::read($input->require(-input=>), $fcmd, $fcmdargs);
             $input->set(-parsing => [$Errors, $Broken, $MissingInput]);
             $ref
         });
    } else {
        # $input is either a string (filename) or reference.
        local $| = 1 if $DEBUG;
        print "\nData::Rlist::open_input($input, $fcmd, $fcmdargs)" if $DEBUG;
        return undef unless open_input($input, $fcmd, $fcmdargs);
        confess unless defined $Readstruct;
        my $data = parse();
        print "\nData::Rlist::close_input() parser result = ", (defined $data) ? $data : 'undef' if $DEBUG;
        close_input();
        return $data;
    }
}

sub read_csv($;$$$);
sub read_csv($;$$$) {
    my($input, $options, $fcmd, $fcmdargs) = @_;

    if (ref($input) eq __PACKAGE__) {
        # $input is an object created by Data::Rlist::new
        $input->dock
        (sub {
             $options ||= $input->get('options');
             $fcmd ||= $input->get('filter');
             $fcmdargs ||= $input->get('filter_args');
             $input = $input->get('input');
             Data::Rlist::read_csv($input, $options, $fcmd, $fcmdargs);
         });
    } else {
        # $input is either a scalar or string-reference: we'll read linewise from a file or a
        # string now.  Note that in case of a string $$input, open_input splits at LF or CR+LF.

        return undef unless open_input($input, $fcmd, $fcmdargs);
        confess unless defined $Readstruct;
        my $delim = complete_options($options)->{delimiter} || $DefaultCsvDelimiter;
        my @L; push @L, $Ln while lexln();
        my @R; push @R,
        map { [ map { maybe_unquote($_) } split_quoted($_, $delim) ] } grep { not /^\s*#|^\s*$/o } @L;
        close_input();
        return \@R;
    }
}

sub read_conf(@) { 
    my($input, $options, $fcmd, $fcmdargs) = @_;
    $options ||= $input->get('options') if ref($input) eq __PACKAGE__;
    $options = complete_options($options) unless ref $options; # expand using predef'd set "default"
    $options->{delimiter} ||= $DefaultConfDelimiter;           # ...where "delimiter" is undef
    return read_csv($input, $options, $fcmd, $fcmdargs);
}

sub read_string($);
sub read_string($) {
    my $r = shift;
    if (defined($r) and not defined reftype($r)) {
        return read_string(\$r);
    } elsif (reftype($r) ne 'SCALAR') {
        carp 'string or string-reference required';
    } Data::Rlist::read($r);
}


sub errors(;$) {
    my $self = shift;
    if ($self) {
        my $a = $self->get(-parsing=>);
        return $a->[0] if ref $a;
        return 0;
    } $Errors
}

sub broken(;$) {
    my $self = shift;
    if ($self) {
        my $a = $self->get(-parsing=>);
        return $a->[1] if ref $a;
        return 0;
    } $Broken
}

sub missing_input(;$) {
    my $self = shift;
    if ($self) {
        my $a = $self->get(-parsing=>);
        return $a->[2] if ref $a;
        return 0;
    } $MissingInput
}

=head3 F<write()>, F<write_csv()> and F<write_string()>

=over

=item F<write(DATA[, OUTPUT, OPTIONS, HEADER])>

Transliterates Perl data into Rlist text.  F<write()> is auto-exported as F<L</WriteData>()>.

B<PARAMETERS>

=over

=item DATA

Either an object generated by F<L</new>()>, or any Perl data including F<undef>.  When DATA is some
F<Data::Rlist> object the Perl data to be compiled is defined by its F<-data> attribute. (When
F<-data> refers to another Rlist object, this other object is invoked.)

=item OUTPUT

Where to compile to.  Defaults to the F<-output> attribute when DATA defines an object.  Defines a
filename to create, or some string-reference.  When F<undef> writes to some new string to which it
returns a reference

=item OPTIONS

How to compile the text from DATA.  Defaults to the F<-options> attribute when DATA is an object.
When F<undef> or C<"fast"> uses F<L</compile_fast>()>, when C<"perl"> uses F<L</compile_Perl>()>,
otherwise F<L</compile>()>.

=item HEADER

Reference to an array of strings that shall be printed literally at the top of an output
file. Defaults to the F<-header> attribute when DATA is an object.

=back

B<RESULT>

When F<write()> creates a file it returns 0 for failure or 1 for success.  Otherwise it returns a
string reference.

B<EXAMPLES>

    $self = new Data::Rlist(-data => $thing, -output => $output);

    $self->write;   # Write into some file (if $output is a filename)
                    # or string (if $output is a string reference).

    new Data::Rlist(-data => $self)->write; # Another way to do it :-)

    Data::Rlist::write($thing, $output);    # dto., applying the functional interface

    print $self->make_string;               # Print $thing to stdout.

    print Data::Rlist::make_string($thing); # dto.

    PrintData($thing);                      # dto.

=item F<write_csv(DATA[, OUTPUT, OPTIONS, COLUMNS, HEADER])>

=item F<write_conf(DATA[, OUTPUT, OPTIONS, HEADER])>

Write DATA as comma-separated-values (CSV) to file or string OUTPUT.  F<write_conf()> writes
configuration files where each line contains a tagname, a separator and a value.  The main
difference between F<write_conf()> and F<write_csv()> are the default values for C<"separator"> and
C<"auto_quote"> (see OPTIONS below).

B<PARAMETERS>

=over

=item DATA, OUTPUT

Please see F<L</write>()>.  Like with F<write()> DATA defines the data to be compiled.  But because
of the limitations of CSV-files this may not be just any Perl data.  It must be a reference to an
array of array references, where each contained array defines the fields. For example,

    [ [ a, b, c ],      # line 1
      [ d, e, f, g ],   # line 2
        .
        .
    ]

Likewise, F<write_conf()> expects

    [ [ tag, value ],   # line 1
        .
        .
    ]

=item OPTIONS

From L<OPTIONS|/Compile Options> is read the comma-separator (C<"separator">), how to quote
(C<"auto_quote">), the linefeed (C<"eol_space">) and the numeric precision (C<"precision">).  The
defaults are:

    FUNCTION        SEPARATOR   AUTO-QUOTING
    --------        ---------   ------------
    write_csv()     ','         no
    write_conf()    ' = '       yes

When OPTIONS is omitted, in an object context this argument is read from the F<-options> attribute.

=item COLUMNS

If specified this shall be an array-ref defining the column names to be written as the first line.
When this parameter is omitted, in an object context this argument is read from the F<-columns>
attribute.

=item HEADER

If specified all strings in this array are written as F<#>-comments before the actual data.  When
this parameter is omitted, in an object context this argument is read from the F<-header>
attribute.

=back

B<RESULT>

When a file was created both function return 0 for failure or 1 for success.  Otherwise they return
a string reference.

B<EXAMPLES>

Functional interface:

    use Data::Rlist;            # imports WriteCSV

    WriteCSV($thing, "foo.dat");

    WriteCSV($thing, "foo.dat", { separator => '; ' }, [qw/GBKNR VBKNR EL LaD LaD_V/]);

    WriteCSV($thing, \$target_string);

    $string_ref = WriteCSV($thing);

Object-oriented interface:

    $object = new Data::Rlist(-data => $thing, -output => "foo.dat",
                              -options => { separator => '; ' },
                              -columns => [qw/GBKNR VBKNR EL LaD LaD_V/]);

    $object->write_csv;         # Write $thing as CSV to foo.dat
    $object->write;             # Write $thing as Rlist to foo.dat

    $object->set(-output => \$target_string);

    $object->write_csv;         # Write $thing as CSV to $target_string

Please see F<L<read_csv>()> for more examples.

=item F<write_string(DATA[, OPTIONS])>

Stringify any Perl DATA and return a reference to the string.

Like F<L</write>()> but always compiles to a new string to which it returns a reference.  This
means, when called as method and unlike F<L</write>()> this function does not use the F<-output>
attribute.  Also it does not use F<-options>; when OPTIONS are omitted they default to
L<C<"string">|/Predefined Options>.

=back

=head3 F<make_string()> and F<keelhaul()>

=over

=item F<make_string(DATA[, OPTIONS])>

Stringify any Perl DATA and return the string.  This function actually is an alias for
F<${Data::Rlist::L<write_string>(DATA, OPTIONS)}>.  Note, however, that OPTIONS default to
L<C<"default">|/Predefined Options>, not C<"string">.  For example,

    print "\n\$thing dumped: ", Data::Rlist::make_string($thing);

    $self = new Data::Rlist(-data => $thing);

    print "\n\$thing dumped (again): ", $self->make_string;

=item F<keelhaul(DATA[, OPTIONS])>

Do a deep copy of DATA according to L<OPTIONS|/Compile Options>.  DATA is any Perl data, or some
F<Data::Rlist> object.  F<keelhaul()> first compiles DATA to Rlist text, then restores the data
from this text.  Hence by "keelhauling data" one can adjust the accuracy of numbers, break
circular-references and drop F<\*foo{THING}>s.

This is especially useful when DATA had been hatched by some other code, and you don't know whether
it is hierachical, or if typeglob-refs nist inside.  You may then simply keelhaul it to clean it
from its past.  Also multiple data sets can be brought to the same, common basis.

For example, to brings all numbers in

    $thing = { foo => [[.00057260], -1.6804e-4] };

to a certain accuracy, use

    $deep_copy = Data::Rlist::keelhaul($thing, { precision => 4 });

to get a F<$deep_copy> (of F<$thing>) as

    { foo => [[0.0006], -0.0002] }

All number scalars were rounded to 4 decimal places, so they're finally comparable as
floating-point numbers. Likewise one can convert all floats to integers:

    $make_integers =
        new Data::Rlist(-data => $thing, -options => { precision => 0 });

    $thing_without_floats = $make_integers->keelhaul;

When F<keelhaul()> is called in an array context it also returns the text from which the copy had
been built.  For example,

    $deep_copy = Data::Rlist::keelhaul($thing);

    ($deep_copy, $rlist_text) = Data::Rlist::keelhaul($thing);

    $deep_copy = new Data::Rlist(-data => $thing)->keelhaul;

You may then bet that

    die if deep_compare($deep_copy, ReadData(\$rlist_text));

will never die.  (It shouldn't.)

B<NOTES>

F<keelhaul()> won't throw F<die> nor return an error, but be prepared for the following effects:

=over

=item *

F<ARRAY>, F<HASH>, F<SCALAR> and F<REF> references were compiled, whether blessed or not.  (Since
compiling does not store type information, F<keelhaul()> will turn blessed references into barbars
again.)

=item *

F<IO>, F<GLOB> and F<FORMAT> references have been converted into strings.

=item *

Depending on the compile options F<CODE> references were called, deparsed back into their function
bodies, or dropped.

=item *

Depending on the compile options floats had been rounded.

=item *

F<undef>'d array elements had been converted into the default scalar value C<"">.

=item *

Anything deeper than F<$Data::Rlist::MaxDepth> had been thrown away.

=item *

Yet no special methods are triggered to "freeze" and "thaw" an object is called before compiling it
into text, or after parsing it from text.

=back

See also F<L</compile>()>, F<L</equal()>> and F<L</deep_compare>()>

=back

=head2 Static Interface

=head3 F<predefined_options()> and F<complete_options()>

=over

=item F<predefined_options([PREDEF-NAME])>

Get the hash-ref F<$Data::Rlist::PredefinedOptions{PREDEF-NAME}>.  PREDEF-NAME defaults to
L<C<"default">|/Predefined Options>, the options for writing files.

=item F<complete_options([OPTIONS[, BASIC-OPTIONS]])>

Completes OPTIONS with BASIC-OPTIONS: all pairs not already in OPTIONS are copied from
BASIC-OPTIONS.  Both arguments define hashes or some L<predefined options name|/Predefined
Options>, and default to L<C<"default">|/Predefined Options>, the options for writing files.

This function returns a new hash of L<compile options|/Compile Options>.  (Even when OPTIONS
defines a hash it is copied into a new one.)  For example,

    $options = complete_options({ precision => 0 }, 'squeezed')

merges the predefined options for L<C<"squeezed">|/Predefined Options> text (no whitespace at all,
no here-docs, numbers rounded) with a numeric precision of 0.  This converts all floats to
integers.

    $options = complete_options($them, { delimiter => '\s+' })

completes F<$them> by some other hash (that is, copies C<"delimiter"> unless such a key exists in
F<$them>). However, F<$them> is not touched.

=back

=cut

sub predefined_options($) {
    my $name = shift || 'default';
    carp "\nunknown compile-options '$name'" unless exists $PredefinedOptions{$name};
    $PredefinedOptions{$name};
}

sub complete_options(;$$);
sub complete_options(;$$)
{
    my($opts, $base) = (shift||'default', shift||'default');
    my $using_default = ($base eq 'default');
    $opts = predefined_options($opts) unless ref $opts;
    $base = predefined_options($base) unless ref $base;

    # Make a new hash, copy all keys not already in $opts from $base.
    $opts = { %$opts };
    $opts->{_base} = ref($base) ? 'some hash' : $base;
    while (my($k, $v) = each %$base) {
        $opts->{$k} = $v unless exists $opts->{$k}
    }

    # Finally complete $opts with "default" and return the new hash.
    $opts = complete_options($opts) unless $using_default;
    $opts
}

sub write($;$$$);
sub write($;$$$)
{
    my($data, $output) = (shift, shift);
    my($options, $header) = @_;
    local $| = 1 if $DEBUG;

    if (ref($data) eq __PACKAGE__) {
        # $data was created by Data::Rlist->new.
        $data->dock
        (sub {
             $output ||= $data->get('-output');
             $options ||= $data->get('-options');
             $header ||= $data->get('-header');
             Data::Rlist::write($data->get('-data'), $output, $options, $header);
         });
    } else {
        # $data is any Perl data or undef.  Reset package globals, validate $options, then compile
        # $data.

        my $to_string = ref $output || not defined $output;
        my($result, $optname, $fast, $perl);
        $options ||= ($to_string ? 'string' : 'fast');
        unless (ref $options) {
            $fast = 1 if $options eq 'fast';
            $perl = 1 if $options eq 'perl';
            $optname = "'$options'";
            $options = predefined_options($options) unless $fast || $perl;
        } else {
            $optname = "custom, based on '${\($options->{_base} || 'default')}'";
        }
        unless ($fast || $perl) {
            $options->{auto_quote} = 1 unless defined $options->{auto_quote};
        }

        unless ($to_string) {
            # Compile $data into a file named $output.
            #
            # Create new file and exclusively lock it. It is guaranteed that no other process will
            # be able to run flock(FH,2) on the same file while you hold the lock. (Because the OS
            # suspends and blocks other processes.)

            confess $output if not defined $output or ref $output; # or not_valid_pathname($output)
            my($to_stdout, $fh) = $output eq '-';
            if ($to_stdout) {
                open($fh, ">$output") or confess("\nERROR: $!");
            } else {
                (open($fh, ">$output") and flock($fh, 2)) or
                confess("\nERROR: $output: can't create and lock Rlist-file: $!");
            }

            # Build file header.  Compile $data to file $fh.  Then returns undef.  The eval traps
            # die exceptions.

            my $host = eval { use Sys::Hostname; hostname; } || 'some unknown machine';
            my $uid = getlogin || getpwuid($<);
            my $tm = localtime;
            my $prec = (ref $options and defined $options->{precision}) ? $options->{precision} : undef;
            my @header = 
            map { (length) ? "# $_\n" : "#\n" }
            (($to_stdout ? () : 
              ("-*-rlist-generic-*-", "", $output, "",
               "Created $tm on <$host> by user <$uid>.",
               "Random Lists (Rlist) file (see Data::Rlist on CPAN and <http://www.visualco.de>).")),
             ((defined $prec) ? 
              sprintf('Numerical precision: fixed-point, rounded to %d decimal places.', $prec) :
              sprintf('Numerical precision: floating-point.')),
             "Compile options: $optname.", 
             ($header ? ("", @$header) : ("")));
            print $fh @header, "\n";

            unless ($fast || $perl) {
                $result = 1 if compile($data, $options, $fh);
            } else {
                # Note that compile_fast() and compile_Perl() both return a reference to
                # $Data::Rlist::R.
                $result = 1;
                print $fh ${compile_fast($data)} if $fast;
                print $fh ${compile_Perl($data)} if $perl;
            } close $fh;
        } else {
            # Compile $data into string and return a reference to it.
            #
            # At this point $output has to be undef or a string-reference.  In case of the latter a
            # reference to the compiled Rlist is not only returned, but also its value is copied to
            # the string referred to by output.

            confess $output unless not defined $output or ref $output eq 'SCALAR';
            unless ($fast || $perl) {
                $result = compile($data, $options);
                $output = $result if ref $output;
            } else {
                $result = compile_fast($data) if $fast;
                $result = compile_Perl($data) if $perl;
                $$output = $$result if ref $output; # we have to copy, since $result refers to
                                                    # $Data::Rlist::R
            }
        } return $result;
    }
}

sub write_csv($;$$$$);
sub write_csv($;$$$$)
{
    my($data, $output) = (shift, shift);
    my($options, $columns, $header) = @_;
    return 0 unless defined $data;

    if (ref($data) eq __PACKAGE__) {
        # $data was created by Data::Rlist->new.
        $data->dock
        (sub {
             $output ||= $data->get('-output');
             $options ||= $data->get('-options');
             $columns ||= $data->get('-columns');
             $header ||= $data->get('-header');
             Data::Rlist::write_csv($data->get('-data'), $output, $options, $columns, $header);
         });
    } else {
        # $data is any Perl data or undef.  In case of undef returns 0.  When the file could not be
        # created, dies. Otherwise returns 1.
        #
        # Unless a value looks like a number the value is quote()d.  read_csv() uses split_quoted()
        # which keeps quotes and backslashes, then maybe_unquote()s each value.

        $options = complete_options($options, 'default');
        my $to_string = ref $output || not defined $output;
        my($separator, $linefeed, $prec, $auto_quote) = map { $options->{$_} } qw/separator eol_space precision auto_quote/;
        my $result = '';
        $auto_quote = 0 unless defined $auto_quote; # by default quote all non-numbers
        $result.= join($separator, @$columns).$linefeed if $columns;
        $result.= join($linefeed, map {
            join($separator, map { is_number($_)
                                   ? (defined($prec) ? round($_, $prec) : $_)
                                   : ($auto_quote ? maybe_quote($_) : quote($_)) 
                               } @$_) } @$data) if @$data;

        if ($to_string) {
            if (ref $output) {
                $$output = $result; return $output
            } else {
                return \$result;
            }
        } else {
            my($to_stdout, $fh) = ($output eq '-');
            local $| = 1 if $DEBUG;
            if ($to_stdout) {
                open($fh, ">$output") or confess("\nERROR: $!");
            } else {
                (open($fh, ">$output") and flock($fh, 2)) or
                confess("\nERROR: $output: can't create and lock CSV-file: $!");
            }
            # TODO: write $header
            print $fh $result;
            close $fh; 1
        }
    }
}

sub write_conf($;$$$$)
{
    my($data, $output, $options, $header) = @_;
    $options ||= $data->get('options') if ref($data) eq __PACKAGE__;
    my $have_sep = ref($options) && defined $options->{separator};
    $options = complete_options($options) unless ref $options;
    $options->{separator} = $DefaultConfSeparator unless $have_sep;
    return write_csv($data, $output, $options, $header);
}

sub write_string($;$) {
    my($data, $options) = (shift, shift||'string');
    my $strref;
    if (ref($data) eq __PACKAGE__) {
        # When $data was created by Data::Rlist->new defuses a possible -output attribute.  Passing
        # some \$str argument for OUTPUT to write() means to copy the compiled Rlist redundantly to
        # $str.

        my $out = $data->get('output');
        $data->set(-output => undef);
        $strref = Data::Rlist::write($data, undef, $options);
        $data->set(-output => $out);
    } else {
        $strref = Data::Rlist::write($data, undef, $options);
    } return $strref;
}

sub make_string($;$) {
    my($data, $options) = (shift, shift||'default');
    local $MaxDepth = $DefaultMaxDepth if $MaxDepth == 0;
    return ${Data::Rlist::write_string($data, $options)};
}

sub keelhaul($;$) {
    my($data, $options) = (shift, shift);
    carp 'Cannot keelhaul Perl data' if defined $options and $options eq 'perl'; # TODO: eval back
    $options ||= complete_options({ precision => undef }, 'squeezed');
    my $strref = Data::Rlist::write_string($data, $options);
    local $MaxDepth = $DefaultMaxDepth if $MaxDepth == 0;
    my $deep_copy = read_string($strref);
    return wantarray ? ($deep_copy, $strref) : $deep_copy;
}

=head2 Implementation

=head3 F<open_input()> and F<close_input()>

=over

=item F<open_input(INPUT[, FILTER, FILTER-ARGS])>

=item F<close_input()>

Open/close Rlist text file or string INPUT for parsing. Used internally by F<L</read>()> and
F<L</read_csv>()>.

B<PREPROCESSING>

If specified the function preprocesses the INPUT file using FILTER.  Use the special value 1 to
select the default C preprocessor (precisely, F<gcc -E -Wp,-C>).  FILTER-ARGS is an optional string
of additional command-line arguments appended to FILTER.  For example,

    my $foo = Data::Rlist::read("foo", 1, "-DEXTRA")

eventually does not parse F<foo>, but the output of the command

    gcc -E -Wp,-C -DEXTRA foo

Hence within F<foo> C-preprocessor-statements are allowed:

    {
    #ifdef EXTRA
    #include "extra.rlist"
    #endif

        123 = (1, 2, 3);
        foobar = {
            .
            .

B<SAFE CPP MODE>

This slightly esoteric mode involves F<sed> and a temporary file.  It is enabled by setting
F<$Data::Rlist::SafeCppMode> to 1 (the default).  It protects single-line F<#>-comments when FILTER
begins with either F<gcc>, F<g++> or F<cpp>.  F<L</open_input>()> then additionally runs F<sed> to
convert all input lines beginning with whitespace plus the F<#> character. Only the following
F<cpp>-commands are excluded, and only when they appear in column 1:

- F<#include> and F<#pragma>

- F<#define> and F<#undef>

- F<#if>, F<#ifdef>, F<#else> and F<#endif>.

For all other lines F<sed> converts F<#> into F<##>. This prevents the C preprocessor from
evaluating them.  But because of Perl's limited F<open()> function, which isn't able to dissolve
arbitary pipes, the invocation of F<sed> requires a temporary file (created in the same directory
as the input file).  F<L</lexln>()>, the function that feeds the lexical scanner with lines, then
converts F<##> back into comment lines.

Alternately, use F<//> and F</* */> comments and set F<$Data::Rlist::SafeCppMode> to 0.

=back

=cut

sub open_input($;$$)
{
    my($input, $fcmd, $fcmdargs) = @_;
    my($rls, $filename);
    my $rtp = reftype $input;

    carp "\n${\((caller(0))[3])}: filename or scalar-ref required as INPUT" if defined $rtp && $rtp ne 'SCALAR';
    carp "\n${\((caller(0))[3])}: package locked" if $Readstruct;
    $Readstruct = $ReadFh = undef;
    local $| = 1 if $DEBUG;

    if (defined $input) {
        $Readstruct = { };
        unless (ref $input) {
            # Input is a filename, not a string reference.
            $Readstruct->{filename} = $input;

            unless ($fcmd) {
                # Normal mode. No filter-command for input file.  The file is read directly
                # (unfiltered), and the input file will be locked.

                unless (open($Readstruct->{fh}, "<$input") && flock($Readstruct->{fh}, 1)) {
                    # This may not be the end of this script! The caller could have trapped the die
                    # exception in an eval; hence we've to be tidy.

                    $Readstruct = undef;
                    pr1nt('ERROR', "input file '$input'", $!);
                }
            } else {
                $fcmd = "gcc -E -Wp,-C -x c++" if $fcmd == 1;
                $fcmd = "$fcmd $fcmdargs" if $fcmdargs;

                if ($SafeCppMode) {
                    if ($fcmd =~ /^(gcc|g\+\+|cpp)/i) {
                        # Safe cpp mode. Filter input with sed:
                        #
                        # (1) prefix the supported preprocessor commands with a few blanks,
                        #     e.g. "#if 0\n" to " #if 0\n".
                        #
                        # (2) convert '#' at column 1 into '##'. The lexln() function then converts
                        #     '^##' back to '#'.
                        #
                        # This output is then preprocessed.  Note that open() does not support true
                        # pipes, i.e. more than one command. We've to create a temporary file.
                        # This file will receive the output of sed, accessible from
                        # $Readstruct->{fh}.

                        my $sedfh;
                        open($sedfh,
                             "sed ".
                             "'s/^#\\(include\\|pragma\\|if\\|ifdef\\|else\\|endif\\|define\\|undef\\)/  #\\1/;".
                             " s/^#/##/' <$input 2>nul |") ||
                             die("\nERROR: input file '$fcmd': $!");
                        my $tmpfh; $input = "$input.tmp0";
                        $input++ while -e $input;
                        $Readstruct->{tmpfile} = $input;
                        open ($tmpfh, ">$input") || die("\nERROR: temporary file '$input': $!");
                        print $tmpfh readline($sedfh);
                        close $tmpfh;
                        close $sedfh;
                    }
                }

                # Open the file for preprocessing.  If $SafeCppMode we don't open file $input, but
                # $Readstruct->{tmpfile}.

                unless (open($Readstruct->{fh}, "$fcmd $input 2>nul |")) {
                    $Readstruct = undef;
                    pr1nt('ERROR', "preprocessed input '$fcmd $input': $!");
                }
            }

            if (defined $Readstruct) {
                $ReadFh = $Readstruct->{fh};
                $LnArray = undef; 
                $Ln = '';
            }
        } else {
            # Input is string reference.  Split it into lines at LF or CR+LF Note that it isn't
            # necessary for the string to have newlines.

            carp "cannot preprocess strings" if $fcmd;

            # Don't use split_quoted because the input string is arbitary.

            $LnArray = [ split /\r*\n/, $$input ];
            $Ln = '';
        }
    }
    $Readstruct
}

sub close_input()
{
    if ($Readstruct->{fh}) {
        close($Readstruct->{fh});
    }
    if ($Readstruct->{tmpfile}) {
        unlink ($Readstruct->{tmpfile}) || 
        croak "\nERROR: remove temporary file '$Readstruct->{tmpfile}': $!";
    }
    $LnArray = $Ln = $Readstruct = undef
}

=head3 F<lex()> and F<parse()>

=over

=item F<lex()>

Lexical scanner.  Called by F<L</parse>()> to split the current line into tokens.  F<lex()> reads
F<#> or F<//> single-line-comment and F</* */> multi-line-comment as regular white-spaces.
Otherwise it returns tokens according to the following table:

    RESULT      MEANING
    ------      -------
    '{' '}'     Punctuation
    '(' ')'     Punctuation
    ','         Operator
    ';'         Punctuation
    '='         Operator
    'v'         Constant value as number, string, list or hash
    '??'        Error
    undef       EOF

F<lex()> appends all here-doc-lines with a newline character. For example,

        <<test1
        a
        b
        test1

is effectively read as C<"a\nb\n">, which is the same value as the equivalent here-doc in Perl has.
Hence the purpose of the last character (the newline in the last line) is not just to separate the
last line from the delimiter.  As a consequence, not all strings can be encoded as a here-doc.  For
example, it might not be quite obvious to many programmers that C<"foo\nbar"> has no
here-doc-equivalent.

=item F<lexln()>

Read the next line of text from the input.  Return 0 if F<L</at_eof>()>, 1 otherwise.

=item F<at_eof()>

Return true if current input file / string array is exhausted, false otherwise.

=item F<parse()>

Read Rlist language productions from current input, defined by package variables.  This is a fast,
non-recursive parser driven by the parser map F<%Data::Rlist::Rules>, and fed by F<L</lex>()>.

F<parse()> is called internally by F<L</read>()>.

=back

=cut

our $g_re_lex_wsp = qr/^\s+/;
our $g_re_lex_num = qr/^($g_re_float_here)/; # number constant
our $g_re_lex_quoted_string = qr/^\"((?:\\[nrbftv\"\'\\]|\\[0-7]{3}|[^\"])*)\"/; # quoted string constant
our $g_re_lex_name = qr/^($g_re_symbol_here)/; # symbolic name without quotes
our $g_re_lex_quoted_name = qr/^"($g_re_symbol_here)"/; # symbolic name in quotes
our $g_re_lex_punct = qr/^([$g_re_punct_cset])/;

sub lex()
{
    # First throw away leading whitespace.  Since "/o" only affects variable substitution we use
    # precompiled regular expressions.  Set $C1 to ASCII of first character

    LEX_NEXT_TOKEN:
    $Ln =~ s/$g_re_lex_wsp//o;
    while (length($Ln) == 0) {
        return undef unless lexln();
        $Ln =~ s/$g_re_lex_wsp//o;
    }
    $C1 = ord($Ln);

    # Jump over comments. '//' or '#' single-line-comment, '/*' multi-line-comment.

    if ($C1 == 35) {            # '#'
        $Ln = '';
        goto LEX_NEXT_TOKEN;
    } elsif ($C1 == 47) {       # '/'
        if ($Ln =~ /^\/[\*\/]/o) {
            goto LEX_NEXT_TOKEN if $Ln =~ s/^\/\*.*\*\/\s*//x;
            if ($Ln =~ /^\/\//o) {
                $Ln = ''; goto LEX_NEXT_TOKEN;
            }
            while (lexln()) {
                if ($Ln =~ /\*\/(.*)/) {
                    $Ln = $1; goto LEX_NEXT_TOKEN;
                }
            }
            $Readstruct->{lerr} = q(unterminated comment);
            return '??';
        }
    }

    # Number scalars. C language single/double-precision numbers.  Test if $C1 is a digit, '.', '-'
    # or '+'.

    if (($C1 >= 48 && $C1 <= 57) || $C1 == 46 || $C1 == 45 || $C1 == 43) {
        if ($Ln =~ s/$g_re_lex_num//o) {
            push @VStk, $1;
            #print "\nreading number $1";
            return 'v';
        } elsif ($C1 >= 48 && $C1 <= 57) {
            $Readstruct->{lerr} = qq'invalid number "$Ln"';
            return '??';
        } elsif ($Ln =~ s/$g_re_lex_name//o) {
            # Symbolic name (unquoted string) beginning with '-'.
            push @VStk, $1;
            return 'v';
        } else {
            $Readstruct->{lerr} = qq'invalid number "$Ln"';
            return '??';
        }
    }

    # String scalars, un/quoted, here-docs.

    if ($C1 == 60) {           # <<HERE
        if ($Ln =~ s/<<([_\w]+)//i) {
            # Fetch lines until $tok appears at top of a line.  Then continues at $rest of original
            # line. If not EOF the next call to lexln() will return the next line after the line
            # that closed the here-doc.

            my($tok, $rest, @ln, $ok) = ($1, $Ln);
            while ($ok = lexln()) {
                if ($Ln =~ /^$tok\s*$/m) {
                    $Ln = $rest; last;
                } else {
                    push @ln, unescape($Ln)
                }
            }
            unless ($ok) {
                confess unless at_eof();
                $Readstruct->{lerr} = q(EOF while reading here-document '$tok');
                return '??';
            } else {
                push @VStk, join("\n", @ln)."\n"; # add newline to all lines
                return 'v';
            }
        }
    } elsif ($C1 == 34) {       # "
        # String scalar, quoted. Removes the quotes and unesacpes the strings (compile adds
        # quotes).

        if (1) {
            # BUG: the regex engine of perl 5.8.7 (Cygwin) unconditionally exits when it tried to
            # match a large quoted string, e.g. >8000 characters.  perldb provides no hint
            # why. This problem once occurred during intensive testing of this package.

            if (length($Ln) > 1000) {
                #print "string len=".length($Ln)." val = \n\n$Ln\n\n" if $DEBUG;

                # TODO: take a precautionary approach because of bug/misbehaviors in Perl's regex
                # engine now (see above). 
            }
        }

        if ($Ln =~ s/$g_re_lex_quoted_name//o) { # no escape sequences
            push @VStk, $1;
            #print "\nread name : '$1'";
            return 'v';
        } elsif ($Ln =~ s/$g_re_lex_quoted_string//o) { # maybe has escape sequences
            push @VStk, unescape($1);
            #print "\nread string: '", unescape($1), "'";
            return 'v';
        }
    } elsif ($Ln =~ s/$g_re_lex_punct//o) {
        # Punctuator.
        #
        # TODO: return chr($C1). Test wether comparing the ASCII for each punctuator isn't faster.

        return $1;
    } elsif ($Ln =~ s/$g_re_lex_name//o) {
        # Symbolic name (unquoted string). Names are printable and hence have no \NNN sequences.
        push @VStk, $1;
        return 'v';
    }

    # Unrecognized character, e.g. '*'.

    $Readstruct->{lerr} = "cannot read '$Ln'";
    return '??';
}

sub at_eof() {
    if ($ReadFh) {
        return CORE::eof($ReadFh);
    } elsif (defined $LnArray && $#$LnArray != -1) {
        return 0
    } else {
        return 1                # $LnArray undef'd or empty
    }
}

sub lexln() {
    if (at_eof()) {
        # No file to read from, or at EOF.
        $Ln = undef; return 0;
    } else {
        # Not at EOF yet.
        if ($ReadFh) {
            $Ln = readline($ReadFh);
            $Ln =~ s/\r*\n\z//o; # One should really localize $/ in parse() and then chomp $Ln
                                 # here. But I'm worried about the correct value for $/ to really
                                 # make s/\r*\n\z// happen.  Note: don't strip \s* (before \r)
                                 # because this would also affect here-doc-lines; of course it is
                                 # questionable whether they should be allowed to end in horizontal
                                 # whitespace.
            $Ln =~ s/^\s*\#\#/\#/ if $SafeCppMode; # Convert '^##' back to '#'.
        } else {
            $Ln = shift @$LnArray; # from string
        }
        #study $Ln;
        return 1;
    }
}

sub parse()
{
    my($q) = ('');
    my($t, $m, $rule, $l);

    $Errors = $MissingInput = 0;
    @VStk = ();

    #print "\nData::Rlist::parse()" if $DEBUG;

    while (defined($t = lex())) {
        # Push the new input token to token queue $q.  Then reduce as many rules as possible from
        # $q.  The "do" loop runs while a rule was matched. Otherwise it exits and then another
        # token is read from the input string or file.

        $q .= $t;
        do {
            # At tail of $q, try to match rule $m. $m has a length of <= 4, since 4 is the length
            # of the longest rule in the global parser syntax map %Rules.  Then the "while" loop
            # tries to match $m, or less than $m.

            #print "\n\ttokens = $q " if $DEBUG;
            $l = length $q;
            if ($l > 4) {
                $l = 4;
                $m = substr($q, -4);
            } else {
                $m = $q;
            }

            while (1) {
                if (exists $Rules{$m}) {
                    # Found a rule to reduce. Note that using "exists" is faster than
                    #       if (defined($rule = $Rules{$m})
                    # because oftenly a rule $m won't exist.

                    $rule = $Rules{$m};
                    #print qq'\treduced $m => $rule->[0]' if $DEBUG;
                    substr($q, -$l) = $rule->[0];
                    $rule->[1]->(); # apply the rule
                    last;
                } else {
                    # So $m is not a matching rule.
                    #
                    # $l is the current length of $m. If $l<2 no rule can be matched, because 2 is
                    # $rule_min, the length of the smallest rule, and has not matched.  Then we'll
                    # leave the loop and fetch another token or EOF.

                    #print qq' cannot reduce $m' if $DEBUG;
                    last if --$l < 2;

                    # When $l>=2 remove the first character from $m to try the next rule.
                    #
                    # Removing the first character *quickly* from a string is surprisingly hard. All
                    # of the following work:
                    #
                    #   $m = unpack('x1A'.$l, $m)
                    #   $m = substr($m, 1)          # 1
                    #   substr($m, 0, 1) = ''       # 2
                    #
                    # unpack is the slowest, the first substr yet the fastest.  I also tried unpack
                    # with constants 'x1A1', 'x1A2' and 'x1A3' (ca. 10% slower). Then (it was
                    # late...) I had the idea to load the read-only variable $' implicitly using
                    # m//, then in the loop do $'=~m/^./o to remove the first char from $' (but
                    # still ca. 12% slower than the substr).

                    $m = substr($m, 1);
                }
            }
            last if $Errors;    # stop if an error occured
        } while ($l > 1);       # ergo while $m had matched
    }

    if ($Errors) {
        return undef;
    } else {
        # EOF reached, which means lex() had returned undef. The token queue has now been reduced
        # to one token and @VStk only contains its value. The token 'h' (hash) or 'l'
        # (list). Because of the parser map nature it could also be 'v' (value), in which case it
        # shall decay into a hash or list.

        print qq'\nData::Rlist::parse() reached EOF with "$q"' if $DEBUG;

        if (@VStk == 0) {
            # Empty input or non-existing file.
            croak "unexpected, supernumeray tokens after parsing:\n\t$q" if $DEBUG && $q;
            $MissingInput = 1; return undef;
        } else {
            if (@VStk > 1) {
                pr1nt('ERROR', qq'broken input', qq'expected "l" (list) or "h" (hash), not "$q"');
                my @overproduced = map { ref($_) ? $_ : Data::Rlist::quote($_) } @VStk;
                for (my $i = 0; $i <= $#overproduced; ++$i) {
                    pr1nt('WARNING', sprintf("cancelling overbilled value [%u] %s", $i, $overproduced[$i]));
                }
                print qq'\nData::Rlist::parse() returns undef' if $DEBUG;
                return undef;
            } elsif (not defined $VStk[0]) {
                confess         # dto.
            } elsif ($q eq 'v') {
                my $rtp = reftype $VStk[0]; # result type
                unless (defined $rtp) {
                    $VStk[0] = { $VStk[0] => undef } # not a reference - the input is just one scalar
                } elsif ($rtp !~ /(?:HASH|ARRAY)/) {
                    confess quote($VStk[0]) # shall be an array/hash-reference
                }
            }
        }

        print qq'\nData::Rlist::parse() returns '.quote($VStk[0]) if $DEBUG;
        return pop @VStk;
    }
}

=head3 F<compile()>, F<compile_fast()> and F<compile_Perl()>

=over

=item F<compile(DATA[, OPTIONS, FH])>

Build Rlist text from any Perl data DATA.  When FH is defined compile directly to this file and
return 1.  Otherwise (FH is F<undef>) build a string and return a reference to it.

B<HOW DATA IS COMPILED>

=over

=item *

Reference-types F<SCALAR>, F<HASH>, F<ARRAY> and F<REF> are compiled into text, whether blessed or
not.

=item *

Reference-types F<CODE> are compiled depending on the L<C<"code_refs">|/Compile Options> setting in
OPTIONS.

=item *

Reference-types F<GLOB> (L<typeglob-refs|/Background: A Short Story of Typeglobs>), F<IO> and
F<FORMAT> (file- and directory handles) cannot be dissolved.  These are compiled into the strings
C<"?GLOB?">, C<"?IO?"> and C<"?FORMAT?">.

=item *

F<undef>'d values in arrays are compiled into the default Rlist C<"">.

=back

=item F<compile_fast(DATA)>

Build Rlist text from any Perl data DATA.  Do this as fast as actually possible with pure Perl.

B<HOW DATA IS COMPILED>

=over

=item *

Reference-types F<SCALAR>, F<HASH>, F<ARRAY> and F<REF> are compiled into text, whether blessed or
not.  

=item *

F<CODE>, F<GLOB>, F<IO> and F<FORMAT> are compiled into the strings C<"?CODE?">, C<"?IO?">,
C<"?GLOB?"> and C<"?FORMAT?">.  

=item *

F<undef>'d values in arrays are compiled into the default Rlist C<"">.

=back

The main difference to F<L</compile>()> is that F<compile_fast()> considers no compile
options. Thus it cannot call code, implicitly round numbers, and cannot detect recursively-defined
data.

F<compile_fast()> returns a reference to the compiled string, which is a reference to a unique
package variable. Subsequent calls to F<compile_fast()> therefore reassign this variable.

=item F<compile_Perl(DATA)>

Like F<L<compile_fast>()>, but do not compile Rlist text - compile DATA into Perl. It can then be
F<eval>'d.  This renders more compact, and more exact output as L<Data::Dumper>. For example, only
strings are quoted.

Use the compile-option C<"perl"> to trigger this function from F<L</write>()> and
F<L<write_string>()>.

=back

=cut

our($Datatype, $K, $V);
our($Outline_data, $Outline_hashes, $Code_refs, $Here_docs, $Auto_quote, $Precision);
our($Eol_space, $Paren_space, $Bol_tabs, $Comma_punct, $Semicolon_punct, $Assign_punct);

sub compile($;$$)
{
    my($data, $result) = shift;
    my $options = complete_options(shift);

    local($Fh, $Depth, $Broken) = (shift, -1, 0);
    local $RoundScientific = 1 if $options->{scientific};
    local($Eol_space, $Paren_space, $Bol_tabs, 
          $Comma_punct, $Semicolon_punct, $Assign_punct) = map { $options->{$_} }
          qw/eol_space paren_space bol_tabs 
             comma_punct semicolon_punct assign_punct/;

    local($Outline_data, $Outline_hashes,
          $Code_refs, $Here_docs, $Auto_quote, $Precision) = map { $options->{$_} }
          qw/outline_data outline_hashes
             code_refs here_docs auto_quote precision/;

    return compile1($data) unless $Fh; # return string-reference
    return compile2($data);     # return 1
}

sub comptab($) {
    return '' if $Bol_tabs == 0; # no indentation
    return chr(9) x ($Bol_tabs * ($Depth + $_[0])); # use physical TABs
}

sub compval($) {
    # Compile a scalar value (number or string, but not a reference).
    #
    # TODO: to gain more speed, in compile create a specialized sub depending on globals
    # $Precision, $Here_docs.
    #
    my $v = shift;
    if (defined $v) {
        if ($v !~ $g_re_value) {
            # Not an identifier, number or quoted string.  Hence $v will be quoted, and maybe as
            # here-doc.
            if ($Here_docs) {
                if ($v =~ /\n.*\n\z/os) {
                    # Here-docs enabled and $v qualifies.  Note that we want to write only strings
                    # with at least two LFs as here-docs, although a final LF would be sufficient.
                    # Now find a token that doesn't interfere with the text: try "___", "HERE",
                    # "HERE0", "HERE1" etc.

                    my @ln = split /\n/, $v;
                    my $tok = '___';
                    while (1) {
                        last unless grep { /^$tok/ } @ln;
                        if ($tok =~ /\d\z/) {
                            $tok++
                        } else {
                            $tok = $tok !~ 'HERE' ? 'HERE' : 'HERE0'
                        }
                    } $v = join('', map { "$_\n" } ("<<$tok", (map { escape($_) } @ln), $tok));
                } else {
                    $v = quote($v)
                }
            } else {
                $v = quote($v)
            }
        } elsif (ord($v) != 34) {
            # Not already quoted.  Either $v is a number or a symbolic name.
            if ($Auto_quote) {
                if ($v =~ $g_re_float) {
                    $v = round($v, $Precision) if defined $Precision;
                } else {
                    die $v unless $v =~ $g_re_symbol;
                    $v = qq("$v");
                }
            } elsif (defined $Precision) {
                $v = round($v, $Precision) if $v =~ $g_re_float;
            }
        }
    } $v
}

sub compile1($);
sub compile1($)
{
    # Compile Perl data structure $data into some Rlist and return a string reference.

    my $data = shift;
    my($r, $inl, $k, $v);

    if (ref $data) {
        $Datatype = ord reftype $data;
        $Depth++;
        if ($MaxDepth >= 1 && $MaxDepth < $Depth) {
            pr1nt('ERROR', "compile1() broken in deep $data (max-depth = $MaxDepth)") unless $Broken++;
            $r = DEFAULT
        } elsif ($Datatype == 65) { # 65 => 'A' => 'ARRAY'
            my $cnt = @$data;
            unless ($cnt) {
                $r = '('.$Paren_space.')';
            } elsif ($Outline_data > 0 && $Outline_data <= $cnt) {
                # List has more than $Outline_data number of configured elements; print each
                # element on a separate line.

                my($pref0, $pref) = (comptab(0), comptab(1));
                $r.= $Eol_space.$pref0.'('.$Eol_space.$pref;

                # BUG: for some strange reason it destroys $data if assigning the result of the
                # recursive compile1() call to $v again.  Perl 5.8.6,
                # cygwin-thread-multi-64int. Solution: assign temporarily to $w.

                my $w;
                foreach $v (@$data) {
                    $w = ${compile1($v)};
                    $r.= $Comma_punct.$Eol_space.$pref if $inl; $inl = 1;
                    $r.= $w;
                }
                $r.= $Eol_space.$pref0.')';
            } else {
                # Print all entries to one line.

                my $w;
                $r.= '('.$Paren_space;
                foreach $v (@$data) {
                    $w = ${compile1($v)};
                    $r.= $Comma_punct if $inl; $inl = 1;
                    $r.= $w;
                }
                $r.= $Paren_space if $inl;
                $r.= ')';
            }
        } elsif ($Datatype == 72) { # 72 => 'H' => 'HASH'
            my @keys = sort keys %$data;
            unless (@keys) {
                $r = '{'.$Paren_space.'}';
            } else {
                my $manykeys = $Outline_data && @keys;
                my($pref0, $pref) = (comptab(0), comptab(1));
                foreach $k (@keys) {
                    $v = $data->{$k};
                    unless ($inl) { # prepare first pair
                        $r.= $Eol_space.$pref0 if $Outline_hashes && $manykeys;
                        $r.= '{'.$Paren_space;
                        $r.= $Eol_space if $manykeys; $inl = 1;
                    }
                    $k = $pref.(($k !~ $g_re_value) ? quote($k) : $k);
                    unless (defined($v)) {
                        $r.= $k.$Semicolon_punct.$Eol_space; # value is undef
                    } else {
                        $v = ${compile1($v)};
                        $r.= $k.$Assign_punct.$v.$Semicolon_punct.$Eol_space;
                    }
                }
                $r.= $pref0 if $manykeys;
                $r.= '}';
                $r.= $Eol_space unless $Depth;
            }
        } elsif ($Datatype == 82) { # 82 => 'R' => 'REF'
            $r.= ${compile1($$data)}
        } elsif ($Datatype == 83) { # 83 => 'S' => 'SCALAR'
            $r.= compval($$data);
        } elsif ($Datatype == 67) { # 67 => 'C' => 'CODE'
            $r.= $Code_refs ? ${compile1($data->())} :  '"?CODE?"'
        } else {                # other reference: 'IO', 'GLOB' or 'FORMAT'
            $r.= compval('?'.reftype($data).'?')
        }
        $Depth--;
    } elsif (defined $data) {   # $data is some scalar (not a ref)
        $r = compval($data);
    } else {                    # $data is undefined
        $r = DEFAULT
    } \$r;
}

sub compile2($);
sub compile2($)
{
    # Compile Perl data structure $data into some Rlist and directly print into file handle $Fh (do
    # not compile a big string such as compile1() does).
    #
    # WARNING: this shall be merely a copy of the compile1() code.

    my $data = shift;
    my($inl, $k, $v);

    if (ref $data) {
        $Datatype = ord reftype $data;
        $Depth++;
        if ($MaxDepth >= 1 && $MaxDepth < $Depth) {
            pr1nt('ERROR', "compile2() broken in deep $data (depth = $Depth, max-depth = $MaxDepth)") unless $Broken++;
            print $Fh "\n", DEFAULT;
        } elsif ($Datatype == 65) { # 65 => 'A' => 'ARRAY'
            my $cnt = 1 + $#$data;
            unless ($cnt) {
                print $Fh '('.$Paren_space.')';
            } elsif ($Outline_data > 0 && $Outline_data <= $cnt) {
                # List has more than the number of configured elements; print each element on a
                # separate line.

                my($pref0, $pref) = (comptab(0), comptab(1));
                print $Fh $Eol_space.$pref0.'('.$Eol_space.$pref;
                foreach $v (@$data) {
                    print $Fh $Comma_punct.$Eol_space.$pref if $inl; $inl = 1;
                    compile2($v);
                }
                print $Fh $Eol_space.$pref0.')';
                print $Fh $Eol_space unless $Depth;
            } else {
                # Print all entries to one line.
                print $Fh '('.$Paren_space;
                foreach $v (@$data) {
                    print $Fh $Comma_punct if $inl; $inl = 1;
                    compile2($v);
                }
                print $Fh $Paren_space if $inl;
                print $Fh ')';
            }
        } elsif ($Datatype == 72) { # 72 => 'H' => 'HASH'
            my @keys = sort keys %$data;
            unless( @keys ) {
                print $Fh '{'.$Paren_space.'}';
            } else {
                my $manykeys = $Outline_data && @keys;
                my($pref0, $pref) = (comptab(0), comptab(1));
                foreach $k (@keys) {
                    $v = $data->{$k};
                    unless ($inl) {
                        print $Fh $Eol_space.$pref0 if $Outline_hashes && $manykeys;
                        print $Fh '{'.$Paren_space;
                        print $Fh $Eol_space if $manykeys; $inl = 1;
                    }
                    $k = $pref.(($k !~ $g_re_value) ? quote($k) : $k);
                    unless (defined($v)) {
                        print $Fh $k.$Semicolon_punct.$Eol_space; # value is undef
                    } else {
                        print $Fh $k.$Assign_punct;
                        compile2($v);
                        print $Fh $Semicolon_punct.$Eol_space;
                    }
                }
                print $Fh $pref0 if $manykeys;
                print $Fh '}';
                print $Fh $Eol_space unless $Depth;
            }
        } elsif ($Datatype == 82) { # 82 => 'R' => 'REF'
            compile2($$data)
        } elsif ($Datatype == 83) { # 83 => 'S' => 'SCALAR'
            print $Fh compval($$data);
        } elsif ($Datatype == 67) { # 67 => 'C' => 'CODE'
            if ($Code_refs) {
                compile2($data->())
            } else {
                print $Fh '"?CODE?"'
            }
        } else {                # other reference: 'IO', 'GLOB' or 'FORMAT'
            print $Fh compval('?'.reftype($data).'?')
        }
        $Depth--;
    } elsif (defined $data) {   # $data is some scalar (not a ref)
        print $Fh compval($data);
    } else {                    # $data is undefined
        print $Fh DEFAULT;
    } 1
}

sub compile_fast($)
{
    my $data = shift;
    $R = ''; $Depth = -1;       # reset result string
    compile_fast1($data); # return a string reference
    return \$R; # reference to the package-variable $Data::Rlist::R
}

sub compile_fast1($);
sub compile_fast1($)
{
    # Undefined values always are compiled into the default Rlist, the empty string.
    #
    # ord() returns 0 when reftype is undef, which it is for scalars.  For any reference, blessed
    # or not, reftype returns "HASH", "ARRAY", "CODE" or "SCALAR".  The $Datatype approach is
    # significantly faster than testing whether ref($data)=~'ARRAY' etc.

    my $data = $_[0];

    if (ref $data) {
        $Datatype = ord reftype $data;
        $Depth++;
        if ($Datatype == 65) {  # 65 => 'A' => 'ARRAY'
            # Open arrays in lines of their own, like we do also with hashes. The approach is fast
            # and compiles legible text.  Lists of lists (matrices) then look nice.

            if (@$data) {
                $R.= chr(10).(chr(9) x $Depth).'(';
                my $in = 0;
                foreach (@$data) {
                    unless ($in) { $in = 1 } else { $R.= ', ' }
                    if (defined) {
                        if (ref) {
                            compile_fast1($_)
                        } else {
                            $R.= $_ !~ $g_re_value ? quote($_): $_
                        }
                    } else { $R.= DEFAULT }
                } $R.= ')';
            } else { $R .= '()' }
        } elsif ($Datatype == 72) {   # 72 => 'H' => 'HASH'
            if (%$data) {
                my $pref = chr(9) x $Depth;

                # Sorting is slightly slower than
                #       while (($K, $V) = each %$data)
                # but produces much nicer results.  Note also that calling is_random_text is
                # generally faster than to quote always.

                $R.= "{\n";
                foreach $K (sort keys %$data) {
                    $V = $data->{$K};
                    $K = quote($K) if $K !~ $g_re_value;
                    $R.= $pref.chr(9).$K;
                    if (defined $V) {
                        $R.= ' = ';
                        if (ref $V) {
                            compile_fast1($V);
                        } else {
                            $V = quote($V) if $V !~ $g_re_value;
                            $R.= $V;
                        }
                    } $R.= ";\n";
                } $R.= $pref.'}';
            } else {
                $R.= '{}'
            }
        } elsif ($Datatype == 82) { # 82 => 'R' => 'REF'
            compile_fast1($$data)
        } elsif ($Datatype == 83) { # 83 => 'S' => 'SCALAR'
            $R.= ($$data !~ $g_re_value) ? quote($$data) : $$data;
        } else {                # other reference: 'CODE', 'IO', 'GLOB' or 'FORMAT'
            $R.= '"?'.reftype($data).'?"'
        }
        $Depth--;
    } elsif (defined $data) {   # number or string
        $R.= ($data !~ $g_re_value) ? quote($data) : $data;
    } else {                    # undef
        $R.= DEFAULT;
    }
}

sub compile_Perl($)
{
    my $data = shift;
    $R = ''; $Depth = -1;       # reset result string
    compile_Perl1($data);
    return \$R; # reference to the package-variable $Data::Rlist::R
}

sub compile_Perl1($);
sub compile_Perl1($)
{
    my $data = $_[0];
    sub __quote($) {
        my $s = shift;
        return $s if $s =~ /^["']/;
        return quote($s);
    }

    if (ref $data) {
        $Datatype = ord reftype $data;
        $Depth++;
        if ($Datatype == 65) {
            if (@$data) {
                $R.= chr(10).(chr(9) x $Depth).'[';
                my $in = 0;
                foreach (@$data) {
                    unless ($in) { $in = 1 } else { $R.= ', ' }
                    if (defined) {
                        if (ref) {
                            compile_Perl1($_)
                        } else {
                            $R.= is_number($_) ? $_ : __quote($_)
                        }
                    } else { $R.= DEFAULT }
                } $R.= ']';
            } else { $R .= '[]' }
        } elsif ($Datatype == 72) {
            if (%$data) {
                my $pref = chr(9) x $Depth;
                $R.= "{\n";
                foreach $K (sort keys %$data) {
                    $V = $data->{$K};
                    $K = __quote($K) unless is_number($K);
                    $R.= $pref.chr(9).$K;
                    if (defined $V) {
                        $R.= ' => ';
                        if (ref $V) {
                            compile_Perl1($V);
                        } else {
                            $V = __quote($V) unless is_number($V);
                            $R.= $V;
                        }
                    } $R.= ",\n";
                } $R.= $pref.'}';
            } else {
                $R.= '{}'
            }
        } elsif ($Datatype == 82) {
            compile_Perl1($$data)
        } elsif ($Datatype == 83) {
            $R.= is_number($data) ? $$data : __quote($$data);
        } else {
            $R.= '"?'.reftype($data).'?"'
        }
        $Depth--;
    } elsif (defined $data) {   # number or string
        $R.= is_number($data) ? $data : __quote($data);
    } else {                    # undef
        $R.= DEFAULT;
    }
}

=head2 Auxiliary Functions

The utility functions in this section are generally useful when handling stringified data.  These
functions are either very fast, or smart, or both.  For example, F<L</quote>()>, F<L</unquote>()>,
F<L</escape>()> and F<L</unescape>()> internally use precompiled regexes and precomputed ASCII
tables; so employing these functions is probably faster then using own variants.

=head3 F<is_number()>, F<is_symbol()> and F<is_random_text()>

=over

=item F<is_integer(SCALAR-REF)>

Returns true when a scalar looks like an +/- integer constant.  The function applies the compiled
regex F<$Data::Rlist::g_re_integer>.

=item F<is_number(SCALAR-REF)>

Test for strings that look like numbers. F<is_number()> can be used to test whether a scalar looks
like a integer/float constant (numeric literal). The function applies the compiled regex
F<$Data::Rlist::g_re_float>.  Note that it doesn't match

- the IEEE 754 notations of Infinite and NaN,

- leading or trailing whitespace,

- lexical conventions such as the C<"0b"> (binary), C<"0"> (octal), C<"0x"> (hex) prefix to denote a
  number-base other than decimal, and

- Perls' legible numbers, e.g. F<3.14_15_92>.

See also

    perldoc -q "whether a scalar is a number"

=item F<is_symbol(SCALAR-REF)>

Test for symbolic names.  F<is_symbol()> can be used to test whether a scalar looks like a symbolic
name.  Such strings need not to be quoted.  Rlist defines symbolic names as a superset of C
identifier names:

    [a-zA-Z_0-9]                    # C/C++ character set for identifiers
    [a-zA-Z_0-9\-/\~:\.@]           # Rlist character set for symbolic names

    [a-zA-Z_][a-zA-Z_0-9]*                  # match C/C++ identifier
    [a-zA-Z_\-/\~:@][a-zA-Z_0-9\-/\~:\.@]*  # match Rlist symbolic name

For example, scoped/structured names such as F<std::foo>, F<msg.warnings>, F<--verbose>,
F<calculation-info> need not be quoted. (But if they're quoted their value is exactly the same.)
Note that F<is_symbol()> does not catch leading or trailing whitespace. Another restriction is that
C<"."> cannot be used as first character, since it could also begin a number.

=item F<is_value(SCALAR-REF)>

Returns true when the scalar is an integer, a number, a symbolic name or some string returned by
F<L</quote>()>.

=item F<is_random_text(SCALAR-REF)>

The opposite of F<L<is_value>()>.  On such text F<L</compile>()> amd F<L</compile_fast>()>
call F<L</quote>()>.

=back

=cut

sub is_integer(\$) { ${$_[0]} =~ $g_re_integer ? 1 : 0 }
sub is_number(\$) { ${$_[0]} =~ $g_re_float ? 1 : 0 }
sub is_symbol(\$) { ${$_[0]} =~ $g_re_symbol ? 1 : 0 }
sub is_value(\$) { ${$_[0]} =~ $g_re_value ? 1 : 0 }
sub is_random_text(\$) { ${$_[0]} =~ $g_re_value ? 0 : 1 }

=head3 F<quote()>, F<escape()> and F<unhere()>

=over

=item F<quote(TEXT)>

=item F<escape(TEXT)>

Converts TEXT into 7-bit-ASCII.  All characters not in the set of the 95 printable ASCII characters
are escaped (see below).  The following ASCII codes will be converted to escaped octal numbers,
i.e. 3 digits prefixed by a slash:

    0x00 to 0x1F
    0x80 to 0xFF
    " ' \

The difference between the two functions is that F<quote()> additionally places TEXT into
double-quotes.  For example, F<quote(qq'"FrE<uuml>her Mittag\n"')> returns C<"\"Fr\374her
Mittag\n\"">, while F<escape()> returns C<\"Fr\374her Mittag\n\">

=item F<maybe_quote(TEXT)>

Return F<quote(TEXT)> if F<L</is_random_text>(TEXT)>; otherwise (TEXT defines a symbolic name or
number) return TEXT.

=item F<maybe_unquote(TEXT)>

Return F<unquote(TEXT)> when the first character of TEXT is C<">; otherwise returns TEXT.

=item F<unquote(TEXT)>

=item F<unescape(TEXT)>

Reverses F<L</quote>()> and F<L</escape>()>.

=item F<unhere(HERE-DOC-STRING[, COLUMNS, FIRSTTAB, DEFAULTTAB])>

HERE-DOC-STRING shall be a L<here-document|/Here-Documents>. The function checks whether each line
begins with a common prefix, and if so, strips that off.  If no prefix it takes the amount of
leading whitespace found the first line and removes that much off each subsequent line.

Unless COLUMNS is defined returns the new here-doc-string. Otherwise, takes the string and
reformats it into a paragraph having no line more than COLUMNS characters long. FIRSTTAB will be
the indent for the first line, DEFAULTTAB the indent for every subsequent line. Unless passed,
FIRSTTAB and DEFAULTTAB default to the empty string C<"">.

This function combines recipes 1.11 and 1.12 from the Perl Cookbook.

=back

=cut

our(%g_nonprintables_escaped,   # keys are non-printable ASCII chars, values are escape sequences
    %g_escaped_nonprintables,   # keys are escaped sequences, values are the non-printables
    $g_re_nonprintable,
    $g_re_escape_seq);

BEGIN {
    # Perl should not use/require the same module twice. However, the die exception below may fire
    # in case Rlist.pm is symlinked.  For example, when Rlist.pm is installed locally to ~/bin and
    # ~/bin is in @INC, one can say:
    #       use Rlist;
    # to read the package Data::Rlist.  But in order to
    #       use Data::Rlist;
    # as with the regularily installed version (from CPAN), one must create ~/bin/Data/Rlist.pm.
    # If this is a symlink to ~/bin/Rlist.pm the same file might be used twice.

    croak "${\(__FILE__)} used/required twice" if %g_escaped_nonprintables;

    # Tabulate octalization. In previous versions escape() was implemented so
    #
    #   sub _octl {
    #       $n = ord($1);
    #       '\\'.($n >> 6).(($n >> 3) & 7).($n & 7);
    #   }
    #   s/([\x00-\x1F\x80-\xFF])/_octl()/ge # non-printables => \NNN
    #
    # which has now been optimized into
    #
    #   s/$g_re_nonprintable/$g_nonprintables_escaped{$1}/go
    #

    sub escape_char($) {
        my $c = ord($_[0]); # get number code, eg. 'ü' => 252
        '\\'.($c >> 6).(($c >> 3) & 7).($c & 7); # eg. 252 => \374
    }

    sub unescape_char($) {      # w/o leading backslash
        pack('C', oct($_[0]));  # deoctalize eg. 11 => 9 => \t
    }

    $g_re_escape_seq = qr/\\([0-7]{1,3}|[nrt"'\\])/;
    $g_re_nonprintable = qr/([\x00-\x1F\x80-\xFF"'])/;

    # Build tables for non-printable ASCII chararacters.

    %g_nonprintables_escaped = map { chr($_) => escape_char(chr($_)) } (0x00..0x1F, 0x80..0xFF);
    my @v = values %g_nonprintables_escaped;
    foreach (@v) {
        s/^\\// or die;
        croak $_ if exists $g_escaped_nonprintables{$_};
        $g_escaped_nonprintables{$_} = unescape_char($_)
    }

    croak unless keys(%g_nonprintables_escaped) == (255 - 95);
    croak join("  ", keys %g_escaped_nonprintables) unless keys(%g_escaped_nonprintables) == (255 - 95);
    #croak sort keys %g_escaped_nonprintables;

    # Add \ " ' into the tables, which spares another s// call in escape and unescape for
    # them. The leading \ is alredy matched by $g_re_escape_seq.

    $g_nonprintables_escaped{chr(34)} = qq(\\"); # " => \"
    $g_nonprintables_escaped{chr(39)} = qq(\\'); # ' => \'

    $g_escaped_nonprintables{chr(34)} = chr(34);
    $g_escaped_nonprintables{chr(39)} = chr(39);
    $g_escaped_nonprintables{chr(92)} = chr(92);

	# Add \r, \n and \t.

	if (1) {
		$g_nonprintables_escaped{chr( 9)} = qq(\\t); # \t => \\t
		$g_nonprintables_escaped{chr(10)} = qq(\\n); # \n => \\n
		$g_nonprintables_escaped{chr(13)} = qq(\\r); # \r => \\r

		$g_escaped_nonprintables{'t'} = chr( 9);
		$g_escaped_nonprintables{'n'} = chr(10);
		$g_escaped_nonprintables{'r'} = chr(13);
	}
}

sub maybe_quote($) { is_random_text($_[0]) ? quote($_[0]) : $_[0] }
sub maybe_unquote($) { ord($_[0]) == 34 ? unquote($_[0]) : $_[0] }

sub quote($) {
    # Escape, then add quotes (the below expression is faster than qq).
    '"'.escape($_[0]).'"'
}

sub unquote($) {
    # First remove quotes, then unescape. The below expression might look complicated; but it is
    # actually faster than to shift the string from the stack, massage it with s/^\"// and s/\"$//.

    unescape(ord($_[0]) == 34 ? substr($_[0], 1, length($_[0]) - 2) : $_[0])
}

sub escape($) {
    my $s = shift; return '' unless defined $s;
    $s =~ s/\\/\\\\/g;											 # has to happen first, because...
    $s =~ s/$g_re_nonprintable/$g_nonprintables_escaped{$1}/gos; # ...will intersperse more backslashes
    $s
}

sub unescape($) {
    my $s = shift;
    $s =~ s/$g_re_escape_seq/$g_escaped_nonprintables{$1}/gos;
    $s
}

sub unhere($;$$$) {
    # Combines recipes 1.11 and 1.12.
    local $_ = shift;
    my($white, $leader);        # common whitespace and common leading string
    if (/^\s*(?:([^\w\s]+)(\s*).*\n)(?:\s*\1\2?.*\n)+$/) {
        ($white, $leader) = ($2, quotemeta($1));
    } else {
        ($white, $leader) = (/^(\s+)/, '');
    }
    s/^\s*?$leader(?:$white)?//gm;

    # Recipe 1.12
    my($columns, $firsttab, $deftab) = (shift, shift||'', shift||'');
    if ($columns) {
        use Text::Wrap;
        $Text::Wrap::columns = $columns;
        return wrap($firsttab, $deftab, $_);
    } else {
        return $_;
    }
}

=head3 F<split_quoted()>

=over

=item F<split_quoted(INPUT[, DELIMITER])>

=item F<parse_quoted(INPUT[, DELIMITER])>

Divide the string INPUT into a list of strings.  DELIMITER is a regular expression specifying where
to split (default: C<'\s+'>).  The function won't split at DELIMITERs inside quotes, or which are
backslashed.  For example, to split INPUT at commas use C<'\s*,\s*'>.

F<parse_quoted()> works like F<split_quoted()> but additionally removes all quotes and backslashes
from the splitted fields.  Both functions effectively simplify the interface of
F<Text::ParseWords>.  In an array context they return a list of substrings, otherwise the count of
substrings. An empty array is returned in case of unbalanced C<"> quotes, e.g.
F<split_quoted(C<'foo,"bar'>)>.

B<EXAMPLES>

F<split_quoted()>:

    sub split_and_list($) {
        print ($i++, " '$_'\n") foreach split_quoted(shift)
    }

    split_and_list(q("fee foo" bar))

        0 '"fee foo"'
        1 'bar'

    split_and_list(q("fee foo"\ bar))

        0 '"fee foo"\ bar'

The default DELIMITER C<'\s+'> handles newlines.  F<split_quoted(C<"foo\nbar\n">)> returns
S<F<('foo', 'bar', '')>> and hence can be used to to split a large string of uncho(m)p'd input
lines into words:

    split_and_list("foo  \r\n bar\n")

        0 'foo'
        1 'bar'
        2 ''

The DELIMITER matches everywhere outside of quoted constructs, so in case of the default C<'\s+'>
you may want to remove heading/trailing whitespace. Consider

    split_and_list("\nfoo")
    split_and_list("\tfoo")

        0 ''
        1 'foo'

and

    split_and_list(" foo ")

        0 ''
        1 'foo'
        2 ''

F<parse_quoted()> additionally removes all quotes and backslashes from the splitted fields:

    sub parse_and_list($) {
        print ($i++, " '$_'\n") foreach parse_quoted(shift)
    }

    parse_and_list(q("fee foo" bar))

        0 'fee foo'
        1 'bar'

    parse_and_list(q("fee foo"\ bar))

        0 'fee foo bar'

B<MORE EXAMPLES>

String C<'field\ one  "field\ two"'>:

    ('field\ one', '"field\ two"')  # split_quoted
    ('field one', 'field two')      # parse_quoted

String C<'field\,one, field", two"'> with a DELIMITER of C<'\s*,\s*'>:

    ('field\,one', 'field", two"')  # split_quoted
    ('field,one', 'field, two')     # parse_quoted

Split a large string F<$soup> (mnemonic: slurped from a file) into lines, at LF or CR+LF:

    @lines = split_quoted($soup, '\r*\n');

Then transform all F<@lines> by correctly splitting each line into "naked" values:

    @table = map { [ parse_quoted($_, '\s*,\s') ] } @lines

Here is some more complete code to parse a F<.csv>-file with quoted fields, escaped commas:

    open my $fh, "foo.csv" or die $!;
    local $/;                   # enable localized slurp mode
    my $content = <$fh>;        # slurp whole file at once
    close $fh;
    my @lines = split_quoted($content, '\r*\n');
    die q(unbalanced " in input) unless @lines;
    my @table = map { [ map { parse_quoted($_, '\s*,\s') } ] } @lines

You may also use F<L</read_csv>()>.  A nice way to make sure what F<split_quoted()> and
F<parse_quoted()> return is using F<L<deep_compare>()>.  For example, the following code shall
never die:

    croak if deep_compare([split_quoted("fee fie foo")], ['fee', 'fie', 'foo']);
    croak if deep_compare( parse_quoted('"fee fie foo"'), 1);

The 2nd call to F<L</parse_quoted>()> happens in scalar context, hence shall return 1 because
there's one string to parse.

=back

=cut

sub split_quoted($;$) {
    # Split [0] at delimiter [1], returning a list of words/tokens.  Delimiter defaults to '\s+'.
    #
    # We've to map the result of parse_line again to build the result. For "foo\nbar\n" parse_line
    # returns ('foo','bar',undef), not ('foo','bar',''). This may cause hard to track "Use of
    # uninitialized value..."  warnings.

    use Text::ParseWords;
    return map { (defined) ? $_ : DEFAULT } parse_line($_[1]||'[\s]+', 1, $_[0])
}

sub parse_quoted($;$) {
    use Text::ParseWords;
    return map { (defined) ? $_ : DEFAULT } parse_line($_[1]||'[\s]+', 0, $_[0])
}

=head3 F<equal()> and F<round()>

=over

=item F<equal(NUM1, NUM2[, PRECISION])>

=item F<round(NUM1[, PRECISION])>

Compare and round floating-point numbers. F<L</equal>()> returns true if NUM1 and NUM2 are equal to
PRECISION (default: 6) number of decimal places.  NUM1 and NUM2 are string- or number scalars.

Normally F<round()> will return a number in fixed-point notation.  When the package-global
F<$Data::Rlist::RoundScientific> is true F<round()> formats the number in either normal or
exponential (scientific) notation, whichever is more appropriate for its magnitude.  This differs
slightly from fixed-point notation in that insignificant zeroes to the right of the decimal point
are not included. Also, the decimal point is not included on whole numbers.  For example,
F<L</round>(42)> does not return 42.000000, and F<round(0.12)> returns 0.12, not 0.120000.

B<MACHINE ACCURACY>

One needs a function like F<L</equal>()> to compare floats, because IEEE 754 single- and double
precision implementations are not absolute - in contrast to the numbers they actually represent.
In all machines non-integer numbers are only an approximation to the numeric truth.  In other
words, they're not commutative! For example, given two floats F<a> and F<b>, the result of F<a+b>
might be different than that of F<b+a>.

Each machine has its own accuracy, called the F<machine epsilon>, which is the difference between 1
and the smallest exactly representable number greater than one. Most of the time only floats can be
compared that have been carried out to a certain number of decimal places.  In general this is the
case when two floats that result from a numeric operation are compared - but not two constants.
(Constants are accurate through to lexical conventions of the language. The Perl and C syntaxes for
numbers simply won't allow you to write down inaccurate numbers in code.)

See also recipes 2.2 and 2.3 in the Perl Cookbook.

B<EXAMPLES>

    CALL                    RETURNS NUMBER
    ----                    --------------
    round('0.9957', 3)       0.996
    round(42, 2)             42
    round(0.12)              0.120000
    round(0.99, 2)           0.99
    round(0.991, 2)          0.99
    round(0.99, 1)           1.0
    round(1.096, 2)          1.10
    round(+.99950678)        0.999510
    round(-.00057260)       -0.000573
    round(-1.6804e-6)       -0.000002

=back

=cut

sub equal($$;$) {
    my($a, $b, $prec) = @_;
    $prec = 6 unless defined $prec;
    sprintf("%.${prec}g", $a) eq sprintf("%.${prec}g", $b)
}

sub round($;$) {
    # Note that sprintf("%.6g\n", 2006073104) yields 2.00607e+09, which looses digits.
    my $a = shift; return $a if is_integer($a);
    my $prec = shift; $prec = 6 unless defined $prec;
    return sprintf("%.${prec}g", $a) if $RoundScientific;
    return sprintf("%.${prec}f", $a);
}

=head3 F<deep_compare()>

=over

=item F<deep_compare(A, B[, PRECISION, PRINT])>

Compare and analyze two numbers, strings or references. Generates a log (stack of messages)
describing exactly all unequal data.  Hence, for any Perl data F<$a> and F<$b> one can assert:

    croak "$a differs from $b" if deep_compare($a, $b);

When PRECISION is defined all numbers in A and B are F<L</round>()>ed before actually comparing them.
When PRINT is true traces progress on F<stdout>.

B<RESULT>

Returns an array of messages, each describing unequal data, or data that cannot be compared because
of type- or value-mismatching.  The array is empty when deep comparison of A and B found no unequal
numbers or strings, and only indifferent types.

B<EXAMPLES>

The result is line-oriented, and for each mismatch it returns a single message:

    Data::Rlist::deep_compare(undef, 1)

yields

    <<undef>> cmp <<1>>   stop! 1st undefined, 2nd defined (1)

Some more complex example.  Deep-comparing two multi-level data structures A and B returned two
messages:

    'String literal' == REF(0x7f224)   stop! type-mismatch (scalar versus REF)
    'Greetings, earthlings!' == CODE(0x7f2fc)   stop! type-mismatch (scalar versus CODE)

Somewhere in A a string C<"String literal"> could not be compared, because the F<corresponding>
element in B is a reference to a reference. Next it says that C<"Greetings, earthlings!"> could not
be compared because the corresponding element in B is a code reference. (One could assert, however,
that the actual opacity here is that F<they> speak ASCII.)

Actually, A and B are identical. B was written to disk (by F<L</write>()>)and then read back as A
(by F<L</read>()>).  So, why don't they compare anymore?  Because in B the refs F<REF(0x7f224)> and
F<CODE(0x7f2fc)> hide

    \"String literal"

and

    sub { 'Greetings, earthlings!' }

When writing B to disk F<write()> has dissolved the scalar- and the code-reference into C<"String
literal"> and C<"Greetings, earthlings!">. Of course, F<deep_compare()> will not do that, so A does
not compare to B anymore.  Note that despite these two mismatches, F<deep_compare()> had continued
the comparision for all other elements in A and B.  Hence the structures are otherwise identical.

=back

=cut

sub deep_compare($$;$$$);
sub deep_compare($$;$$$)
{
    use Scalar::Util qw/reftype blessed looks_like_number/;

    my($a, $b, $prec, $dump, $ind) = @_;
    my(@R, $r);
    my $prind = sub(@) { foreach (@_) { print chr(9) x $ind, $_ } };
    my $result = sub {
        my $s = 'stop! '.shift();
        $prind->($ind, "   $s") if $dump;
        push @R, "$r   $s"
    };
    my $round = sub($) { defined($prec) ? round(shift(), $prec) : shift() };
    my $arf = ref($a);          # ref returns undef on non-refs
    my $brf = ref($b);
    my $atp = reftype($a);
    my $btp = reftype($b);
    my $anm = (defined $arf) && looks_like_number($a);
    my $bnm = (defined $brf) && looks_like_number($b);
    my $fmt = sub(@) {          # format number and string for printing
        map { s/\r/\\r/g; s/\t/\\t/g; $_ }
        map {
            (not defined) ? 'undef' :
            (ref) ? $_ : looks_like_number($_) ? $round->($_) : qq"'$_'"
        } @_
    };

    $arf = ($anm ? 'number' : defined($a) ? 'string' : 'undef') unless $arf;
    $brf = ($bnm ? 'number' : defined($b) ? 'string' : 'undef') unless $brf;

    if (1) {
        my @s = $fmt->($a, $b);
        my @t = map { $_ ? " as $_" : "" } ($atp, $btp);
        $r = "<<$s[0]>>$t[0] ".($anm ? '==' : 'cmp')." <<$s[1]>>$t[0]";
        if ($dump) {
            print chr(10); $prind->($r);
        }
    }

    if (not defined $a and not defined $b) {
        print "\tboth undef" if $dump;
        return @R;
    }

    if ((defined $a) and (not defined $b)) {
        $result->("1st defined, 2nd not ($a)");
        return @R;
    } elsif (not defined $a and defined $b) {
        $result->("1st undefined, 2nd defined ($b)");
        return @R;
    }

    unless ($arf eq $brf) {
        $result->("type-mismatch ($arf versus $brf)");
        return @R;
    }
    #$result->("reference-types do not match ($atp != $btp)") unless $atp eq $btp;

    unless (defined $atp) {
        if ($anm) {
            #($a, $b) = map { round($_, $prec) } ($a, $b) if defined $prec;
            if (defined $prec) {
                $a = round($a, $prec);
                $b = round($b, $prec);
                $prec = " (precision=$prec)";
            } else {
                $prec = " (precision=none)";
            }
            unless (equal($a, $b)) {
                $result->("unequal numbers$prec")
            } elsif ($dump) {
                print "\tidentical numbers$prec"
            }
        } elsif ($a ne $b) {
            $result->("unequal strings")
        } elsif ($dump) {
            print "\tidentical strings"
        }
        return @R
    } elsif ($atp eq 'SCALAR') {
        push @R, deep_compare($$a, $$b, $prec, $dump, $ind + 1);
        return @R
    } elsif ($atp eq 'HASH') {
        # Deep-compare two hashes.  First test number of key/value-pairs.
        my $acnt = keys %$a;
        my $bcnt = keys %$b;
        unless ($acnt == $bcnt) {
            $result->("different number of keys ($acnt, $bcnt)");
            return @R;          # then don't test the keys
        } return @R if $acnt == 0;

        # Although both hashes have an equal number of keys, make sure that the keys themselves are
        # equal.

        my @a_keys_missing = grep { not exists $b->{$_} } keys %$a;
        my @b_keys_missing = grep { not exists $a->{$_} } keys %$b;

        if (@a_keys_missing || @b_keys_missing) {
            $result->("1st hash misses keys (".join(', ', $fmt->(@a_keys_missing)).")") if @a_keys_missing;
            $result->("2nd hash misses keys (".join(', ', $fmt->(@b_keys_missing)).")") if @b_keys_missing;
            return @R;
        }

        # Then compare all values.

        foreach (keys %$a) {
            $prind->("comparing values of key '$_'") if $dump;
            push @R, deep_compare($a->{$_}, $b->{$_}, $prec, $dump, ($ind||0) + 1);
        }
    } elsif ($atp eq 'ARRAY') {
        # Deep-compare two arrays.

        if ($#$a != $#$b) {
            $result->("different array sizes ($#$a, $#$b)")
        } else {
            for (my $i = 0; $i < $#$a; ++$i) {
                push @R, deep_compare($a->[$i], $b->[$i], $prec, $dump, ($ind||0) + 1);
            }
        }
    } elsif ($atp eq 'REF') {
        # Reference to reference.

        $prind->("dereferencing") if $dump;
        deep_compare($$a, $$b, $prec, $dump, $ind + 1)
    } else {
        $result->("cannot compare reference-type $atp");
    }
    return @R;
}

=head3 F<fork_and_wait()> and F<synthesize_pathname()>

=over

=item F<fork_and_wait(PROGRAM[, ARGS...])>

Forks a process and waits for completion.  The function will extract the exit-code, test whether
the process died and prints status messages on F<stderr>.  F<fork_and_wait()> hence is a handy
wrapper around the built-in F<system()> and F<exec()> functions.  Returns an array of three values:

    ($exit_code, $failed, $coredump)

F<$exit_code> is -1 when the program failed to execute (e.g. it wasn't found or the current user
has insufficient rights).  Otherwise F<$exit_code> is between 0 and 255.  When the program died on
receipt of a signal (like F<SIGINT> or F<SIGQUIT>) then F<$signal> stores it. When F<$coredump> is
true the program died and a F<core> file was written.  (Note that some systems store F<core>s
somewhere else than in the programs' working directory.)

=item F<synthesize_pathname(TEXT...)>

Concatenates and forms all TEXT strings into a symbolic name that can be used as a pathname.
F<synthesize_pathname()> is a useful function to reuse a string, assembled from multiple strings,
coinstantaneously as hash key, database name, and file- or URL name.  Note, however, that few
characters are mapped to only C<"_"> and C<"-">.

=back

=cut

sub fork_and_wait(@)
{
    my $prog = shift;
    my($exit_code, $signal, $coredump);
    local $| = 1;
    system($prog, @_);          # == 0 or die "\n\tfailed: $?";
    if ($? == -1) {             # not found
        $exit_code = -1;
        print STDERR "\n\tfailed to execute program: $!\n";
    } elsif ($? & 127) {        # died
        $exit_code = -1;
        $signal = ($? & 127);
        $coredump = ($? & 128);
        print STDERR "\n\tchild died with signal %d, %s core-dump\n", $signal, $coredump ? 'with' : 'without';
    } else {                    # ok
        $exit_code = $? >> 8;
        printf STDERR "\n\tchild exited with value %d\n", $exit_code if $DEBUG;
    }
    return ($exit_code, $signal, $coredump)
}

sub synthesize_pathname(@)
{
    my @s = @_;
    my($dch1, $dch2) = ('-', '_');
    join('_', map { my
                    # Unquote.
                    $s =~ s/^"(.+)"\z/$1/;
                    # Escape all non-printables.
                    $s = escape($_);
                    # Undo \" \'
                    $s =~ s/\\(["'])/$1/go;
                    $s =~ s/[']/_/g;
                    $s =~ s/"(.+)"/$dch2$dch2$1$dch2$dch2/o; # "xxx" within string => __xxx__
                    # Handle \NNN
                    $s =~ s/[\\]/0/g; # eg. \347 => 0347
                    # Filename
                    $s =~ s/[\(\|\)\/:;]/$dch1/go; # ( | ) / : ; ==> -
                    $s =~ s/[\^<>:,;\"\$\s\?!\&\%\*]/$dch2/go; # ^ < > " $ ? ! & % * , ; : wsp => _
                    $s =~ s/^[\-\s]+|[\-\s]+\z//o;
                    $s
                } @s
        )
}

=head2 Exported Functions

=head3 Exporter Tags

Three tags are available that import function sets. These are utility functions usable also
separately from F<Data::Rlist>.

=over

=item F<:floats>

Imports F<L</equal>()>, F<L</round>()> and F<L</is_number>()>.

=item F<:strings>

Imports F<L</maybe_quote>()>, F<L</quote>()>, F<L</escape>()>, F<L</unquote>()>, F<L</unescape>()>,
F<L</unhere>()>, F<L</is_random_text>()>, F<L</is_number>()>, F<L</is_symbol>()>, F<L</split_quoted>()>, and
F<L</parse_quoted>()>.

=item F<:options>

Imports F<L</predefined_options>()> and F<L</complete_options>()>.

=item F<:aux>

Imports F<L</deep_compare>()>, F<L</fork_and_wait>()> and F<L</synthesize_pathname>()>.

=back

For example,

    use Data::Rlist qw/:floats :strings/;

=head3 Auto-Exported Functions

The following functions are implicitly imported into the callers symbol table.  (But you may say
F<require Data::Rlist> instead of F<use Data::Rlist> to prohibit auto-import.  See also
L<perlmod>.)

=over

=item F<ReadData(INPUT[, FILTER, FILTER-ARGS])>

=item F<ReadCSV(INPUT[, OPTIONS, FILTER, FILTER-ARGS])>

=item F<ReadConf(INPUT[, OPTIONS, FILTER, FILTER-ARGS])>

Another way to call F<Data::Rlist::L</read>()>, F<Data::Rlist::L</read_csv>()> and
F<Data::Rlist::L</read_conf>()>.

=item F<WriteData(DATA[, OUTPUT, OPTIONS, HEADER])>

=item F<WriteCSV(DATA[, OUTPUT, OPTIONS, COLUMNS, HEADER])>

=item F<WriteConf(DATA[, OUTPUT, OPTIONS, HEADER])>

Another way to call F<Data::Rlist::L</write>()>, F<Data::Rlist::L</write_csv>()> and
F<Data::Rlist::L</write_conf>()>.

=item F<OutlineData(DATA[, OPTIONS])>

=item F<StringizeData(DATA[, OPTIONS])>

=item F<SqueezeData(DATA[, OPTIONS])>

Another way to call F<Data::Rlist::L</make_string>()>.  F<OutlineData()> applies the predefined
L<C<"outlined">|/Predefined Options> options, while F<StringizeData()> applies
L<C<"string">|/Predefined Options> and F<SqueezeData>() L<C<"squeezed">|/Predefined Options>.  When
specified, OPTIONS are merged into the predefined set by means of F<L<complete_options>()>.  For
example,

    print "\n\$thing: ", OutlineData($thing, { precision => 12 });

F<L<rounds|/round>()> all numbers in F<$thing> to 12 digits.

=item F<PrintData(DATA[, OPTIONS])>

Another way to say

    print OutlineData(DATA, OPTIONS);

For example,

    print OutlineData($thing);

=item F<KeelhaulData(DATA[, OPTIONS])>

=item F<CompareData(A, B[, PRECISION, PRINT_TO_STDOUT])>

Another way to call F<L</keelhaul>()> and F<L</deep_compare>()>. For example,

    use Data::Rlist;
        .
        .
    my($copy, $as_text) = KeelhaulData($thing);

=back

=cut

sub ReadCSV($;$$$) {
    my($input, $options, $fcmd, $fcmdargs) = @_;
    Data::Rlist::read_csv($input, $options, $fcmd, $fcmdargs);
}

sub ReadConf($;$$$) {
    my($input, $options, $fcmd, $fcmdargs) = @_;
    Data::Rlist::read_conf($input, $options, $fcmd, $fcmdargs);
}

sub ReadData($;$$) {
    my($input, $fcmd, $fcmdargs) = @_;
    Data::Rlist::read($input, $fcmd, $fcmdargs);
}

sub WriteCSV($;$$$$) {
    my($data, $output, $options, $columns, $header) = @_;
    Data::Rlist::write_csv($data, $output, $options, $columns, $header);
}

sub WriteConf($;$$$) {
    my($data, $output, $options, $header) = @_;
    Data::Rlist::write_conf($data, $output, $options, $header);
}

sub WriteData($;$$$) {
    my($data, $output, $options, $header) = @_;
    Data::Rlist::write($data, $output, $options, $header);
}

sub PrintData($;$) {
    print OutlineData(@_)
}

sub OutlineData($;$) {          # return outlined data as string
    my($data, $options) = @_;
    Data::Rlist::make_string($data, complete_options($options, 'outlined'));
}

sub StringizeData($;$) { # return data as compact string (mainly this means no newlines)
    my($data, $options) = @_;
    Data::Rlist::make_string($data, complete_options($options, 'string'));
}

sub SqueezeData($;$) { # return data as very compact string (no whitespace at all)
    my($data, $options) = @_;
    Data::Rlist::make_string($data, complete_options($options, 'squeezed'));
}

sub KeelhaulData($;$) {         # recursively copy data
    my($data, $options) = @_;
    Data::Rlist::keelhaul($data, $options);
}

sub CompareData($$;$$) {        # recursively compare data
    my($a, $b, $prec, $dump) = @_;
    Data::Rlist::deep_compare($a, $b, $prec, $dump);
}

=head1 NOTES

The F<Random Lists> (Rlist) syntax is inspired by NeXTSTEP's F<Property Lists>.  Rlist is simpler,
more readable and more portable.  The Perl, C and C++ implementations are fast, stable and free.
Markus Felten, with whom I worked a few month in a project at Deutsche Bank, Frankfurt in summer
1998, arrested my attention on Property lists.  He had implemented a Perl variant of it
(F<L<http://search.cpan.org/search?dist=Data-PropertyList>>).

The term "Random" underlines the fact that the language

=over

=item *

has four primitive/anonymuous types;

=item *

the basic building block is a list, which is combined at random with other lists.

=back

Hence the term F<Random> does not mean F<aimless> or F<accidental>.  F<Random Lists> are
F<arbitrary> lists.

=head2 Rlist vs. Perl Syntax

Rlists are not Perl syntax:

    RLIST    PERL
    -----    ----
     5;       { 5 => undef }
     "5";     { "5" => undef }
     5=1;     { 5 => 1 }
     {5=1;}   { 5 => 1 }
     (5)      [ 5 ]
     {}       { }
     ;        { }
     ()       [ ]

=head2 Speeding up Compilation (Explicit Quoting)

Much work has been spent to optimize F<Data::Rlist> for speed.  Still it is implemented in pure
Perl (no XS).  A very rough estimate for Perl 5.8 is "each MB takes one second per GHz".  For
example, when the resulting Rlist file has a size of 13 MB, compiling it from a Perl script on a
3-GHz-PC requires about 5-7 seconds.  Compiling the same data under Solaris, on a sparcv9 processor
operating at 750 MHz, takes about 18-22 seconds.

The process of compiling can be speed up by calling F<L</quote>()> explicitly on scalars. That is,
before calling F<L</write>()> or F<L</write_string>()>.  Large data sets may compile faster when
for scalars, that certainly not qualify as symbolic name, F<L</quote>()> is called in advance:

    use Data::Rlist qw/:strings/;

    $data{quote($key)} = $value;
        .
        .
    Data::Rlist::write("data.rlist", \%data);

instead of

    $data{$key} = $value;
        .
        .
    Data::Rlist::write("data.rlist", \%data);

It depends on the case whether the first variant is faster: F<L</compile>()> and
F<L</compile_fast>()> both have to call F<L</is_random_text>()> on each scalar.  When the scalar is
already quoted, i.e. its first character is C<">, this test ought to run faster.

Note that internally F<L</is_random_text>()> applies the precompiled regex F<$g_re_value>.  But for
a given scalar F<$s> the expression S<F<($s !~ $Data::Rlist::g_re_value)>> can be up to 20% faster
than the equivalent F<is_random_text($s)>.

=head2 Quoting strings that look like numbers

Normally you don't have to care about strings, since un/quoting happens as required when
reading/compiling Rlists from Perl data.  A common problem, however, occurs when some text fragment
(string) uses the same lexicography than numbers do.

Printed text uses well-defined glyphs and typographic conventions, and finally the competence of
the reader to recognize numbers.  But computers need to know the exact number type and format.
Integer?  Float?  Hexadecimal?  Scientific?  Klingon?  The Perl Cookbook in recipe 2.1 recommends
the use of a regular expression to distinguish number from string scalars.  The advice illustrates
how hard the problem actually is.  Not only Perl has to come over this; any program that interprets
text has to.

Since Perl scripts are texts that process text into more text, Perl's artful answer was to define
F<typeless scalars>. Scalars hold a number, a string or a reference. Therewith Perl solves the
problem that digits, like alphabetics and punctuations, are regular ASCII codes.  So Perl defines
F<the string> as the basic building block for all program data. Venturesome it then lets the
program decide F<what strings mean>.  Analogical, in a printed book the reader has to decipher the
glyphs and decide what evidence they hide.

In Rlist, string scalars that look like numbers need to be quoted explicitly.  Otherwise, for
example, the scalar F<$s=C<"-3.14">> appears as F<-3.14> in the output. Likewise C<"007324"> is
compiled into 7324 - the text quality is lost and the scalar is read back as a number.  Of course,
this behavior is by intend, and in most cases this is just what you want. For hash keys, however,
it might be a problem.  One solution is to prefix the string by an artificial C<"_">:

    my $s = '-9'; $s = "_$s";

Since the scalar begins with a C<"_"> it does not qualify as a number anymore, and hence is
compiled as string, and read back as string.  In the C++ implementation it will then become some
F<std::string>, not a F<double>.  But the leading C<"_"> has to be removed by the reading program.
Perhaps a better solution is to explicitly call F<Data::Rlist::quote>:

    $k = -9;
    $k = Data::Rlist::quote($k); # returns qq'"-9"'

    use Data::Rlist qw/:strings/;

    $k = 3.14_15_92;
    $k = quote($k);             # returns qq'"3.141592"'

Again, the need to quote strings that look like numbers is a problem evident only in the Perl
implementation of Rlist, since Perl is a language with weak types. As a language with very strong
typing C++ is quasi the antipode to Perl. With the C++ implementation of Rlist then there's no need
to quote strings that look like numbers.

See also F<L</write>()>, F<L</is_number>()>, F<L</is_symbol>()>, F<L</is_random_text>()> and
F<L<http://en.wikipedia.org/wiki/American_Standard_Code_for_Information_Interchange>>.

=head2 Installing F<Rlist.pm> locally

Installing CPAN packages usually requires administrator privileges.  In case you don't have them,
another way is to copy the F<Rlist.pm> file into a directory of your choice, e.g. into F<.> or
F<~/bin>.  Instead of F<use Data::Rlist;>, however, you then use the following code:

    BEGIN {
        $0 =~ /[^\/]+$/;
        push @INC, $`||'.', "$ENV{HOME}/bin";
        require Rlist;
        Data::Rlist->import();
        Data::Rlist->import(qw/:floats :strings/);
    }

This code finds F<Rlist.pm> also in F<.> and F<~/bin>, and then calls the F<Exporter> manually.

=head2 Package Dependencies

F<Data::Rlist> depends only on few other packages:

    Exporter
    Carp
    strict
    integer
    Sys::Hostname
    Scalar::Util        # deep_compare() only
    Text::Wrap          # unhere() only
    Text::ParseWords    # split_quoted(), parse_quoted() only

F<Data::Rlist> is free of F<$&>, F<$`> or F<$'>. Reason: once Perl sees that you need one of these
meta-variables anywhere in the program, it has to provide them for every pattern match.  This may
substantially slow your program (see also L<perlre>).

=head2 Background: A Short Story of Typeglobs

F<This is supplement information for L</compile>().>

Typeglobs are an idiosyncracy of Perl. Perl uses a symbol table per package (namespace) to map
symbolic names like F<foo> to Perl values.  Humans use abstract symbols to name things, because we
can remember symbols better than numbers, or formulas that hide numbers.

Typeglob objects are symbol table entries.

The idiosyncracy is that different types need only one entry - one symbol can name all types of
Perl data (scalars, arrays, hashes) and nondata (functions, formats, I/O handles).  For example,
the symbol F<foo> is mapped to the typeglob F<*foo>. Therein coexist F<$foo> (the scalar value),
F<@foo> (the list value), F<%foo> (the hash value), F<&foo> (the code value) and F<foo> (the I/O
handle or the format specifier).  There's no key C<"$foo"> or C<"@foo"> in the symbol table, only
C<"foo">.

The symbol table is an ordinary hash, named like the package with two colons appended.  The main
symbol table's name is thus F<%main::>, or F<%::>.  Internally this is called a F<stash> (for
symbol table hash).  In the C code that implements Perl, F<%::> is the global variable F<defstash>
(default stash).  It holds items in the F<main> package.  But, as if it were a symbol in a stash,
F<perl> arranges it as typeglob-ref:

    $ perl -e 'print \*::'
    GLOB(0x10010f08)

But the root-stash F<defstash> lists stashes from all other packages. For example, the symbol
F<Data::> in stash F<%::> addresses the stash of package F<Data>, and the symbol F<Rlist::> in the
stash F<%Data::> addresses the stash of package F<Data::Rlist>.

Stashes are symbol tables. F<perl> has one stash per package.

All F<\*names::> are actually stash-refs, but Perl calls them globs.

Like all hashes stashes contain string keys, which name symbols, and values which are typeglobs.
In the C implementation of Perl typeglobs have the F<struct> type F<GV>, for F<Glob value>.
In the stashes, typeglobs are F<GV> pointers.

=over

=item *

The typeglob is interposed between the stash and the program's actual values for F<$foo>, F<@foo>
etc.

=item *

The sigil F<*> serves as wildcard for the other sigils F<%>, F<@>, F<$> and F<&>. A F<sigil> is a
symbol created for a specific magical purpose; the name derives from the latin F<sigilum> = seal.

=back

Modifying F<$foo> in a Perl program won't change F<%foo>.  Each typeglob is merely a set of
pointers to separate objects describing scalars, arrays, hashes, functions, formats and I/O
handles.  Normally only one pointer F<*foo> is non-null.  Because typeglobs host pointers,
F<*foo{ARRAY}> is a way to say F<\@foo>. To get a reference to the typeglob for symbol F<*foo> you
say F<*foo{GLOB}>, or F<\*foo>.  But on the other hand it is not quite clear why

    $ perl -e 'exists *foo{GLOB}'
    exists argument is not a HASH or ARRAY element at -e line 1.

To define the scalar pointer in the typeglob F<*foo> you simply say S<F<$foo = 42>>. But you may
also assign a reference to the typeglob:

    $ perl -e '$x = 42; *foo = \$x; print $foo'
    42

Assigning a scalar alters the symbol, not the typeglob:

    $ perl -e '$x = 42; *foo = $x; print *foo'
    *main::42
    $ perl -e '$x = 42; *foo = $x; print *42'
    *main::42

Hmm.

    $ perl -e 'print 1*9'
    9
    $ perl -e 'print *9'
    *main::9

I wish it wouldn't do that.

    $ perl -e '*foo = 42; print $::{42}, *foo'
    *main::42*main::42

Enough, this is very strange.

Maybe the best use of typeglobs are F<Typeglob-aliases>. For example, S<F<*bar = *foo>> aliases the
symbol F<bar> in the stash.  Then the symbols F<foo> and F<bar> point to the same typeglob!  This
means that when you declare S<F<sub foo {}>> after casting the alias, F<bar()> is F<foo()>.  The
penalty, however, is that the F<bar> symbol cannot be easily removed from the stash.  One way is to
say F<local *bar>, wich temporarily assigns a new typeglob to F<bar> with all pointers zeroized.

What is this good for?  This is not quite clear. Obviously it is just an artefact from Perl 4.  In
fact, F<local> typeglob aliases seem to be faster than references, because no dereferencing is
required. For example,

    void f1 { my $bar = shift; ++$$bar }
    void f2 { local *bar = shift; ++$bar }

    f1(\$foo);                  # increments $foo
    f1(*foo);                   # dto., but faster

Note, however, that F<my> variables (lexical variables) are not stored in stashes, and do not use
typeglobs. These variables are stored in a special array, the F<scratchpad>, assigned to each
block, subroutine, and thread. These are real private variables, and they cannot be F<local>ized.
Each lexical variable occupies a slot in the scratchpad; hence is addressed by an integer index,
not a symbol. F<my> variables are like F<auto> variables in C. They're also faster than F<local>s,
because they're allocated at compile time, not runtime. Therefore you cannot declare F<*foo>
lexically:

    $ perl -e 'my(*foo);'
    Can't declare ref-to-glob cast in "my" at -e line 1, near ");"
    Execution of -e aborted due to compilation errors.

Also it is somewhat confusing that F<$foo> and F<@foo> etc. have concrete values, while F<*foo> is
said to be F<*main::foo>:

    $ perl -e 'print *foo'
    *main::foo
    $ perl -e 'package nirvana; use strict; print *foo;'
    *nirvana::foo

Hence the value of a typeglob is a full path into the F<perl> stashes, down from the F<defstash>.
The stash entry is arranged by F<perl> on the fly, even with the F<use strict> pragma in effect.
One needs to get used to the fact that F<*foo> returns a symbol path, not something like

    (SCALAR => \$foo, ARRAY => \@foo)

for all its non-null pointers (in this example, the symbol F<foo> would have had incarnated as
F<$foo> and F<@foo>).

Conclusion: with typeglobs you reach the bedrock of Perl, where the spade bends back.

See also L<perlguts>, L<perlref>, L<perldsc> and L<perllol>.

=head1 BUGS

There are no known bugs, this package is stable.

Deficiencies of this version:

=over

=item *

L<nanoscripts|/Embedded Perl Code> not yet implemented.

=item *

The C<"deparse"> functionality for the C<"code_refs"> L<compile option|/Compile Options> has not
yet been implemented.

=item *

The C<"threads"> L<compile option|/Compile Options> has not yet been implemented.

=item *

IEEE 754 notations of Infinite and NaN not yet implemented.

=item *

F<L<compile_Perl>()> is experimental.

=back

=head1 SEE ALSO

=head2 F<Data::Dumper>

In contrast to the F<Data::Dumper>, F<Data::Rlist> scalars will be properly F<typed> as number or
string.  F<Data::Dumper> writes numbers always as quoted strings, for example

    $VAR1 = {
                'configuration' => {
                                    'verbose' => 'Y',
                                    'importance_sampling_loss_quantile' => '0.04',
                                    'distribution_loss_unit' => '100',
                                    'default_only' => 'Y',
                                    'num_threads' => '5',
                                            .
                                            .
                                   }
            };

where F<Data::Rlist> writes

    {
        configuration = {
            verbose = Y;
            importance_sampling_loss_quantile = 0.04;
            distribution_loss_unit = 100;
            default_only = Y;
            num_threads = 5;
                .
                .
        }
    }

As one can see F<Data::Dumper> writes the data right in Perl syntax, which means the dumped text
can be simply F<eval>'d.  This means data can be restored very fast. Rlists are not quite
Perl-syntax: a dedicated parser is required.  But therefore Rlist text is portable and can be read
from other programming languages, namely C++, where a fast flex/bison-parser in conjunction with a
smart heap management is implemented. So C++ programs, like Perl programs, are able to handle Rlist
files of several hundred MB.

With F<$Data::Dumper::Useqq> enabled it was observed that F<Data::Dumper> renders output
significantly slower than F<L</compile>()>. This is actually suprising, since F<Data::Rlist> tests
for each scalar whether it is numeric, and truely quotes/escapes strings.  F<Data::Dumper> quotes
all scalars (including numbers), and it does not escape strings.  This may also result in some odd
behaviors.  For example,

	use Data::Dumper;
	print Dumper "foo\n";

yields

	$VAR1 = 'foo
	';

while

	use Data::Rlist;
	PrintData "foo\n"

yields

	{ "foo\n"; }

Recall that F<L</parse>()> always returns a list, as array- or hash-reference.

Finally, F<Data::Rlist> generates smaller files. With the default F<$Data::Dumper::Indent> of 2
F<Data::Dumper>'s output is 4-5 times that of F<Data::Rlist>'s, because F<Data::Dumper> recklessly
uses many whitespaces (blanks) instead of horizontal tabulators. This blows up file sizes without
measure. 

=head1 COPYRIGHT/LICENSE

Copyright 1998-2007 Andreas Spindler

Maintained at CPAN (L<http://search.cpan.org/~aspindler>) and the author's site
(L<http://www.visualco.de>). Please send mail to F<rlist@visualco.de>.

This library is free software; you can redistribute it and/or modify it under the same terms as
Perl itself, either Perl version 5.8.8 or, at your option, any later version of Perl 5 you may have
available.

Thank you for your attention.

=cut

1;

### Local Variables:
### buffer-file-coding-system: iso-latin-1
### fill-column: 99
### End:
