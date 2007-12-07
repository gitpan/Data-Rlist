#!/usr/bin/perl
# -*-cperl-*-

=pod

=head1 NAME

Data::Rlist - A lightweight data language for Perl, C and C++

=cut

# $Writestamp: 2007-12-05 20:11:20 eh2sper$
# $Compile: pod2html Rlist.pm >../../Rlist.pm.html$

=head1 SYNOPSIS

    use Data::Rlist;
        .
        .

Data from text:

    $string_ref = Data::Rlist::write_string($data);

    $string     = Data::Rlist::make_string($data);

    $data       = Data::Rlist::read_string($string_ref);

    $data       = Data::Rlist::read_string($string);

Data from files:

            Data::Rlist::write($data, $filename);

    $data = Data::Rlist::read($filename);

Perform safe deep copies of data:

    $deep_copy  = Data::Rlist::keelhaul($data);

The same can be achieved with the object-oriented interface:

    $object = new Data::Rlist(-data => $thing, -output => \$target_string)

F<-data> defines the data to be compiled, and F<-output> where to write the compilation. F<-output>
either defines a string reference or the name of a file:

    $string_ref = $object->write;       # compile $thing, return \$target_string

    $object->set(-output => "$HOME/.foorc"); # refine as filename

    $object->write;                     # write "~/.foorc"

Passing an argument to F<write()> eventually overrides F<-output>:

    $object->write(".barrc");           # write to some other file

F<L</write_string>()> and F<L</make_string>()> make up a string out of thin air, no matter how
F<-output> is set:

    $string_ref = $object->write_string; # write to new string (ignores -output)

    $string     = $object->make_string; # dto. but return string value

    print $object->make_string;         # ...dump $thing to stdout

However, all these functions apply F<-data> as the Perl data to be compiled.  The attribute
F<-input> defines what to parse: F<read()> compiles the text defined by F<-input> back to Perl
data:

    $object->set(-input => \$rlist_language_productions);

    $data = $object->read;

    $data = $object->read($other); # overrides -input attribute

Analog to F<-data> the F<-input> attribute shall be either a string-reference, F<undef> or the name
of a file:

    use Env qw/HOME/;

    $object->set(-input => "$HOME/.foorc");

    $data = $object->read;      # open and parse "~/.foorc"

    $data = $object->read(".barrc"); # parse some other file (override -input)

    $data = $object->read(\$string); # parse some string (override -input)

    $data = $object->read_string($string_or_ref); # dto.

B<KEELHAULING DATA>

F<Data::Rlist> can also create deep-copies of Perl data, a functionality called F<keelhauling>:

    $deep_copy = $object->keelhaul; # create in-depth copy of $thing

The metaphor vividly connotes that F<$thing> is stringified, then compiled back.  See
F<L</keelhaul>()> for why this only sounds useless.  The little brother of F<L</keelhaul>()> is
F<L</deep_compare>()>:

    print join("\n", Data::Rlist::deep_compare($a, $b));

=head1 DESCRIPTION

=head2 Venue

F<Random-Lists> (Rlist) is a tag/value format for text data.  It converts objects into legible,
plain text.  Rlist is a data format language that uses lists of (a) values and (b) tags and values
to structure data. Shortly, to F<stringify objects>.  The design targets the simplest (yet
complete) language for constant data:

- it allows the definition of hierachical data,

- it disallows recursively-defined data,

- it does not consider user-defined types,

- it has no keywords,

- it has no arithmetic expressions,

- it uses 7-bit-ASCII character encoding.

Rlists are not Perl syntax, and can be used also from C and C++ programs.

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

=over

=item Strings and Numbers

    "Hello, World!"

Symbolic names are simply strings consisting only of F<[a-zA-Z_0-9-/~:.@]> characters. For such
strings the quotes are optional:

    foobar   cogito.ergo.sum   Memento::mori

Numbers adhere to the IEEE 754 syntax for integer- and floating-point numbers:

    38   10e-6   -.7   3.141592653589793

=item Array

Arrays are sequential lists:

    ( 1, 2, ( 3, "Audiatur et altera pars!" ) )

=item Hash

Hashes map a key scalar to some value, a subsquent Rlist.  Hashes are associative lists:

    {
        key = value;
        3.14159 = Pi;
        "Meta-syntactic names" = (foo, bar, baz, "lorem ipsum", Acme, ___);
        lonely-key;
    }

=back

=head2 Audience

Rlist is useful as a "glue data language" between different systems and programs, for configuration
files and for persistence layers (object storage).  It attempts to represent the data pure and
untinged, but without breaking its structure or legibility.  The format excels over comma-separated
values (CSV), but isn't as excessive as XML:

=over

=item *

Like CSV the format describes merely the data itself, but the data may be structured in multiple
levels, not just lines.

=item *

Like XML data can be as complex as required, but while XML is geared to markup data within some
continuous text (the document), Rlist defines the pure data structure.  However, for
non-programmers the syntax is still self-evident.

=back

Rlists are built from only four primitives: F<number>, F<string>, F<array> and F<hash>.  The
penalty with Rlist hence is that data schemes are tacit consents between the users of the data (the
programs).

Implementations yet exist for Perl, C and C++, Windows and UN*X. These implementations are stable,
portable and very fast, and they do not depend on other software.  The Perl implementation operates
directly on primitive types, where C++ uses STL types.  Either way data integrity is guaranteed:
floats won't loose their precision, Perl strings are loaded into F<std::string>s, and Perl hashes
and arrays resurrect in as F<std::map>s and F<std::vector>s.

Moreover, a design goal of Rlist was to scale perfectly well: a single text files can express
hundreds of megabytes of data, while the data is readable in constant time and with constant memory
requirements.  This makes Rlist files applicable as "mini-databases" loaded into RAM at program
startup.  For example, L<http://www.sternenfall.de> uses Rlist instead of a MySQL database.

=head2 Number and String

All program data is finally convertible into numbers and strings.  In Rlist number and string
constants follow the C language lexicography.  Strings that look like C identifier names must not
be quoted.

By definition all input is compiled into an array or hash; hashes are the default. For example, the
string C<"Hello, World!"> is compiled into:

    { "Hello, World!" => undef }

Likewise the parser of the C++ implementation by default returns a F<std::map> with one pair. The
default scalar value is the empty string C<"">. In Perl, F<undef>'d list elements are compiled into
C<"">.

Strings are quoted implicitly when building Rlists; when reading them back strings are unquoted.
Quoting means to L<encode characters|/Character Encoding>, then wrap the string into C<">.  You can
can also make use of this functionality by calling F<L</quote>()> and F<L</unquote>()> as separate
functions.

=head2 Here Documents

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

=head2 Character Encoding

Rlist text uses 7-bit-ASCII.  The 95 printable character codes 32 to 126 occupy one character.
Codes 0 to 31 and 127 to 255 require four characters each: the F<\> escape character followed by
the octal code number. For example, the German Umlaut character F<E<uuml>> (252) is translated into
F<\374>.  An exception are codes 93 (backslash), 34 (double-quote) and 39 (single-quote), which are
escaped as

    \\   \"   \'

=head2 Binary Data

Binary data can be represented as base64-encoded string or L<here-document|/Here documents>.

=head2 Embedded Perl Code

Rlists may define embedded programs: F<nanonscripts>.  They're defined as L<here-document|Here
documents> that is delimited with the special string "nanoscript".  For example,

    hello = (<<nanoscript);
    print "Hello, World!";
    nanoscript

After the Rlist has been fully parsed such strings are F<eval>'d in the order of their occurrence.
Within the F<eval> F<%root> or F<@root> defines the root of the current Rlist.

=head2 Comments

Rlist supports multiple forms of comments: F<//> or F<#> single-line-comments, and F</* */>
multi-line-comments.

=head1 EXAMPLES

Basic Rlist values are number and string constants, from which larger structures are built.  All of
the following paragraphs define valid Rlists.

Single strings and numbers:

    "Hello, World!"

    foo                     // compiles to { 'foo' => undef }

    3.1415                  // compiles to { 3.1415 => undef }

Array:

    (1, a, 4, "b u z")      // list of numbers/strings

    ((1, 2),
     (3, 4))                // list of list (4x4 matrix)

    ((1, a, 3, "foo bar"),
     (7, c, 0, ""))         // another list of lists

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

    "Metaphysic-terms" =
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
A Company [that] Makes Everything: Wile E. Coyote's supplier of equipment and gadgets.
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

=head1 PACKAGE DETAILS

=head2 Compile Options

The format of the compiled text and the behavior of F<L</compile>()> can be controlled by the
OPTIONS parameter of F<L</write>()>, F<L</write_string>()> etc.  The argument is a hash defining how
the Rlist text shall be formatted. The following pairs are recognized:

=over

=item 'precision' =E<gt> NUMBER

Unless NUMBER F<undef> round all numbers to the decimal places NUMBER by calling F<L</round>()>.  By
default NUMBER is undef, so F<L</compile>()> does not round floats.

=item 'scientific' =E<gt> FLAG

Causes F<compile()> to masquerade F<$Data::Rlist::RoundScientific>; see F<L</round>()> for the
implications.  Alternately the F<-RoundScientific> object attribute can be set; see F<L</new>()>.

=item 'code_refs' =E<gt> FLAG

If enabled and F<L</write>()> encounters a F<CODE> reference, calls the code, then compiles the
return value.  Disabled by default.

=item 'threads' =E<gt> COUNT

If enabled F<L</compile>()> internally use multiple threads.  Note that this makes only sense on
machines with at least COUNT CPUs.

=item 'here_docs' =E<gt> FLAG

If enabled strings with at least two newlines in them are written in the L<here-doc-format|Here
Documents>.  Note that the string has to be terminated with a C<"\n"> to qualify as here-document.

=item 'auto_quote' =E<gt> FLAG

When true do not quote strings that look like identifiers (by means of F<L<is_name)()>), otherwise
quote F<all> strings.  Note that hash keys are not affected by this flag.  The default is true, but
not for F<L<write_csv>()> and F<L<write_conf>()>, where the default is false (quote all
non-numbers).

=item 'outline_data' =E<gt> NUMBER

Use C<"eol"> (linefeed) to "distribute data on many lines."  Insert a linefeed after every NUMBERth
array value; 0 disables outlining.

=item 'outline_hashes' =E<gt> FLAG

If enabled, and C<"outline_data"> also is also enabled, prints F<{> and F<}> on distinct lines when
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
F<L</compile>()> will always print the C<"eol"> string after the C<"semicolon"> string.

=item 'assign_punct' =E<gt> STRING

String to combine key/value-pairs. Defaults to C<" = ">.  Shall be at least C<"="> to not violate
the compiled Rlist.

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

Compile data in Perl syntax, using F<L</compile_Perl>()>, not F<L</compile>()>.

=item 'fast' or F<undef>

Compile data as fast as possible, using F<L<compile_fast>()>, not compile().

=back

All functions that define an L<OPTIONS|/Compile Options> parameter implicitly call
F<L</complete_options>()> to complete it from one of the predefined set, and C<"default">.
Therefore you may just define a "lazy subset of options" to these functions. For example,

    my $obj = new Data::Rlist(-data => $thing);
    $obj->write('thing.rls', { scientific => 1, precision => 8 });

See also L</complete_options>(), L</predefined_options>() and F<:options>.

=head2 Debugging Data (Finding Self-References)

Debugging (hierachical) data means breaking recursively-defined data.

Set F<$Data::Rlist::MaxDepth> to an integer above 0 to define the depth under which F<L</compile>()>
shall not venture deeper. 0 disables debugging.  When positive compilation breaks on deep
recursions caused by circular references, and on F<stderr> a message like the following is printed:

    ERROR: compile2() broken in deep ARRAY(0x101aaeec) (depth = 101, max-depth = 100)

The message will also be repeated as comment when the compiled Rlist is written to a file.
Furthermore F<$Data::Rlist::Broken> is incremented by one - and compilation continues!  So, any
attempt to venture deeper as suggested by F<$Data::Rlist::MaxDepth> in the data will be blocked,
but compilation continues above that depth.  After F<L</write>()> or F<L</write_string>()> returned,
the caller can check whether F<$Data::Rlist::Broken> is not zero.  Then not all of the data was
compiled into text.

=head2 Quoting strings that look like numbers

Normally you don't have to care about strings, since un/quoting happens as required when
reading/compiling Rlists from Perl data.  A common problem, however, occurs when some text fragment
(string) uses the same lexicography than numbers do.

Printed text uses well-defined glyphs and typographic conventions, and finally the competence of
the reader to recognize numbers.  But computers need to know the exact number type and format to
recognize numbers.  Integer?  Float?  Hexadecimal?  Scientific?  Klingon?  The Perl Cookbook in
recipe 2.1 recommends the use of a regular expression to distinguish number from string scalars.
The advice illustrates how hard the problem actually is.  Not only Perl has to come over this; any
program that interprets text has to.

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
compiled as string, and read back as string.  In the C++ implementation it will then become
F<std::string>, not a F<double>.  But the leading C<"_"> has to be removed by the reading program,
which debunks this technique as a rather poor hack.  Perhaps a better solution is to explicitly
call F<Data::Rlist::quote>:

    $k = -9;
    $k = Data::Rlist::quote($k); # returns qq'"-9"'

    use Data::Rlist qw/:strings/;

    $k = 3.14_15_92;
    $k = quote($k);             # returns qq'"3.141592"'

Again, the need to quote strings that look like numbers is a problem evident only in the Perl
implementation of Rlist, since Perl is a language with weak types. As a language with very strong
typing, C++ is quasi the antipode to Perl. With the C++ implementation of Rlist then there's no
need to quote strings that look like numbers.

See also F<L</write>()>, F<L</is_numeric>()>, F<L</is_name>()>, F<L</is_random_text>()> and
F<L<http://en.wikipedia.org/wiki/American_Standard_Code_for_Information_Interchange>>.

=head2 Speed-up Compilation

Much work has been spent to optimize F<Data::Rlist> for speed.  Still it is implemented in pure
Perl (no XS).  A very rough estimate for Perl 5.8 is "each MB takes one second per GHz".  For
example, when the resulting Rlist file has a size of 13 MB, compiling it from a Perl script on a
3-GHz-PC requires about 5-7 seconds.  Compiling the same data under Solaris, on a sparcv9 processor
operating at 750 MHz, takes about 18-22 seconds.

=head3 Explicit Quoting

The process of compiling can be speed up by calling F<L</quote>()> explicitly on scalars. That is,
before calling F<L</write>()> or F<L</write_string>()>.  Large data sets may compile faster when for
scalars, that certainly not qualify as symbolic name, F<L</quote>()> is called in advance:

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
a given scalar F<$s> the expression

    ($s !~ $Data::Rlist::g_re_value)

can be up to 20% faster than the equivalent F<is_random_text($s)>.

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

            $g_re_punct_cset $g_re_float_here
            $g_re_name_cset $g_re_name_here
            $g_re_integer $g_re_float $g_re_name
            $g_re_value $g_re_value_string/;

use vars qw/$Readstruct $ReadFh $C1 $Ln $LnArray/; # used by open, lex

use constant DEFAULT => qq'""'; # default Rlist, the empty string

BEGIN {
    $VERSION = '1.37';
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
                    is_random_text is_name is_integer is_numeric
                    split_quoted parse_quoted

                    equal round

                    keelhaul deep_compare fork_and_wait synthesize_pathname

                    $g_re_integer $g_re_float $g_re_name/;

    %EXPORT_TAGS = (# Handle IEEE numbers
                    floats => [@EXPORT, qw/equal round is_numeric is_integer/],
                    # Handle (quoted) strings
                    strings => [@EXPORT, qw/maybe_quote quote escape
                                            unquote unescape unhere
                                            is_random_text is_numeric is_integer is_name
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
      auto_quote => undef,		# let write() and write_csv() choose their defaults
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
    # Note that $g_re_name_here shall be defined equal to 'identifier' regex in 'rlist.l'.
    # Otherwise the C/C++ and Perl implementations might not be compatible.  See also the C++
    # function rlist::quote() and the {identifier} rule in rlist.l

    $g_re_punct_cset = '\=\,;\{\}\(\)';
    $g_re_name_cset = 'a-zA-Z_0-9\-/\~:\.@';
    $g_re_name_here = '[a-zA-Z_\-/\~:@]'.qq'[$g_re_name_cset]*';
    $g_re_float_here = '(?:[+-]?)(?=\d|\.\d)\d*(?:\.\d*)?(?:[Ee](?:[+-]?\d+))?';

    $g_re_integer = qr/^[+-]?\d+$/;
    $g_re_float = qr/^$g_re_float_here$/;
    $g_re_name = qr/^$g_re_name_here$/;
    $g_re_value = qr/^"|^$g_re_float_here$|^$g_re_name_here$/;
    $g_re_value_string = qr/^"|^$g_re_name_here/;

    ########
    # Rlist parser-map.
    #
    #   token => [ rule, deduce-function ]
    #   rule  => [ rule, deduce-function ]
    #
    # See `lex()' function for token meanings.

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

=head2 Construct Objects

=head3 F<new()>, F<get()> and F<set()>

These are the core functions to cultivate package objects.

The following functions may be called also as methods: F<L</read>()>, F<L</read_csv>()>,
F<L</read_conf>()>, F<L</read_string>()>, F<L</write>()>, F<L</write_string>()> and
F<L</keelhaul>()>.

=over

=item F<new(ATTRIBUTES)>

ATTRIBUTES is a hash-table defining object attributes.  Example:

    $self = Data::Rlist->new(-input => "foo.rlist", -data => $thing);

B<REGULAR ATTRIBUTES>

    -input => INPUT

Defines what to parse. INPUT defines a filename or string reference.  Applied by F<L</read>()>,
F<L</read_csv>()> and F<L</read_string>()>.

    -data => DATA

Defines the data to be compiled.  DATA is some Perl data.  Applied by F<L</write>()>,
F<L</write_string>()> and F<L</keelhaul>()>.

    -output => OUTPUT (optional)

Defines where to put the compilation: either a filename, string-reference or F<undef>.

    -filter => FILTER (optional)
    -filter-args => FILTER-ARGS (optional)

Used by F<L</read>()> as the preprocessor on the input file. Then applied before parsing. FILTER can
be 1 to select the standard C preprocessor F<cpp>.  Applied by F<L</open_input>()>.

    -delimiter => DELIMITER (optional)

See F<L</read_csv>()>.

    -options => OPTIONS (optional)

Defines the L<compile options|/Compile Options>.

    -header => STRINGS (optional)
    -columns => STRINGS (optional)

Defines the header text (the comments) for data written to files, and the column names of CSV
files.  Used in place of the HEADER parameter of F<L</write>()> and COLUMNS of F<L</write_csv>()>.

B<ATTRIBUTES THAT MASQUERADE PACKAGE GLOBALS>

These attributes raise new values for package globals while object methods are executed.  The new
values are provided by an object that therewith locks the package (in which case
F<$Data::Rlist::Locked> is true.)  When the method returns the previous globals are restored.

    -SafeCppMode => FLAG (optional)

Used by F<L</read>()> to masquerade F<$Data::Rlist::SafeCppMode>.

    -MaxDepth => INTEGER (optional)

Used by F<L</write>()> to masquerade F<$Data::Rlist::MaxDepth>.

	-DefaultCsvDelimiter => REGEX (optional)

F<L</read_csv>()> uses this attribute to masquerade F<$Data::Rlist::DefaultCsvDelimiter>.  REGEX is
then used as a default, when the F<-options> attribute does not specifiy the C<"delimiter"> compile
option.

	-DefaultConfDelimiter => REGEX (optional)

F<L</read_conf>()> uses this attribute to masquerade F<$Data::Rlist::DefaultConfDelimiter>, the
default regex to use when the F<-options> attribute does not specifiy the C<"delimiter">.

	-DefaultConfSeparator => STRING (optional)

F<L</write_conf>()> uses this attribute to masquerade F<$Data::Rlist::DefaultConfSeparator>, the
default string to use when the F<-options> attribute does not specifiy the C<"separator">.

    -RoundScientific => FLAG (optional)

Used by F<L</round>()> during compilation. Masquerades F<$Data::Rlist::RoundScientific>.  Note that
F<round()> is only called when the C<"precision"> option is defined.

=item F<set(SELF[, ATTRIBUTES])>

Reset or initialize object attributes (see F<L</new>()>).  Returns SELF.  Example:

    $obj->set(-input => \$str, -output => 'temp.rls', -options => 'squeezed');

=item F<get(SELF, NAME[, DEFAULT])>

Get some object attribute.  For NAME the leading hyphen is optional.
Unless NAME exists as an attribute returns DEFAULT, or F<undef>.

B<EXAMPLES>

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

sub has($$) {                   # get attribute or return undef
    my($self, $attr) = @_;
    $attr = '-'.$attr unless $attr =~ /^-/;
    exists $self->{$attr};
}

sub dock($\&) {
    # Dock some object to this package.  Save global values, execute some code in the realm of the
    # new globals, restore the globals and return.  See also Recipe 10.13.
    my ($self, $block) = @_;
    carp "package Data::Rlist locked" if $Locked++;
    local $MaxDepth = $self->get(-MaxDepth=>) if $self->has(-MaxDepth=>);
    local $SafeCppMode = $self->get(-SafeCppMode=>) if $self->has(-SafeCppMode=>);
    local $RoundScientific = $self->get(-RoundScientific=>) if $self->has(-RoundScientific=>);
    local $DefaultCsvDelimiter = $self->get(-DefaultCsvDelimiter=>) if $self->has(-DefaultCsvDelimiter=>);
    local $DefaultConfDelimiter = $self->get(-DefaultConfDelimiter=>) if $self->has(-DefaultConfDelimiter=>);
    local $DefaultConfSeparator = $self->get(-DefaultConfSeparator=>) if $self->has(-DefaultConfSeparator=>);
    my $r = $block->();
    $Locked--;
    $r;
}

=head2 Interface

Public functions to be called by users of the package.

=head3 F<read()>, F<read_csv()> and F<read_string()>

=over

=item F<read(INPUT[, FILTER, FILTER-ARGS])>

Parse data structure from INPUT.

B<PARAMETERS>

INPUT shall be either

- some Rlist object created by F<L</new>()>,

- a string reference, in which case F<read()> and F<L</read_string>()> parse Rlist text from it,

- a string scalar, in which case F<read()> assumes a file to open and to parse.

See F<L</open_input>()> for details on the FILTER and FILTER-ARGS parameters, which are used to
preprocess input files before actually reading them.  When specified, and INPUT is an object, they
overload the F<-filter> and F<-filter-args> attributes.

When the input file cannot be F<open>'d and F<flock>'d this function F<die>s.  Note that F<die> is
Perl's mechanism to raise exceptions; they can be catched with F<eval>. For example,

    my $host = eval { use Sys::Hostname; hostname; } || 'some unknown machine';

This code fragment traps the F<die> exception; when it was raised F<eval> returns F<undef>,
otherwise the result of calling F<hostname>. For F<read> this means

    $data = eval { Data::Rlist::read($tempfile) };
    print STDERR "$tempfile not found, is locked or is empty" unless defined $data;

B<RESULT>

F<L</read>()> returns parsed data (reference) or F<undef> if there was no data (when the length of the
physical file is greater than zero it had only comments/whitespace). 

See also F<L</parse>()>, F<L</write>()>, F<L</write_string>()>.

=item F<read_csv(INPUT[, OPTIONS, FILTER, FILTER-ARGS])>

=item F<read_conf(INPUT[, OPTIONS, FILTER, FILTER-ARGS])>

See F<L</read>()> for INPUT and F<L</open_input>()> for FILTER and FILTER-ARGS.  These functions

- read data from strings or files,

- use an optional delimiter,

- ignore delimiters in quoted fields,

- ignore empty lines,

- ignore lines begun with F<#> as comments.

F<L<read_conf>()> is a variant of F<L<read_csv>()> - the difference between both are the default
value for C<"delimiter"> and C<"auto_quote">:

	FUNCTION	DELIMITER	AUTO-QUOTING
	read_csv()	'\s*,\s*'	no
	read_conf()	'\s*=\s*'	yes

The delimiter regexes are actually defined by the package-globals
F<$Data::Rlist::DefaultCsvDelimiter> and F<$Data::Rlist::DefaultConfDelimiter>.  Note, however,
that F<read_csv()> can be used as well for configuration files; use a delimiter of C<'\s+'>, to
split the line at horizontal whitespace into multiple values (but not within quoted strings).

Both functions return a list of lists.  Each embedded array defines the fields in a line, and may
be of variable length.

B<EXAMPLES>

Un/qouting of values happens implicitly.  Given a file F<db.conf>

	# Comment
	SERVER		= hostname
	DATABASE	= database_name
	LOGIN		= "user:password"

the call

	$opts = Data::Rlist::read_conf('db.conf');

returns (as F<$opts>)

	[
		[ 'SERVER', 'hostname' ],
		[ 'DATABASE', 'database_name' ],
		[ 'LOGIN', 'user:password' ]
	]

To convert such an array into a hash C<%conf>, use

	%conf = map { @$_ } @{ReadConf 'db.conf'};

The F<L<write_conf>()> function can be used to update F<db.conf> from F<$opts>, so that

	push @$opts, [ 'MAGIC VALUE' => 3.14_15 ];

	Data::Rlist::write_conf('db.conf', { precision => 2 });

writes

	SERVER = hostname
	DATABASE = database_name
	LOGIN = "user:password"
	"MAGIC VALUE" = 3.14

=item F<read_string(INPUT)>

Calls F<L</read>()> to read Rlist language productions from the string or string-reference INPUT.

=back

=cut

sub is_integer(\$);
sub is_numeric(\$);
sub is_name(\$);
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
                 $fcmdargs = $input->get('-filter-args');
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
			 $fcmdargs ||= $input->get('filter-args');
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
	$options->{delimiter} ||= $DefaultConfDelimiter;		   # ...where "delimiter" is undef
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

=head3 F<write()>, F<write_csv()> and F<write_string()>

=over

=item F<write(DATA[, OUTPUT, OPTIONS, HEADER])>

Translates Perl data into some Rlist, i.e. into printable text.  DATA is either an object generated
by F<L</new>()>, or some Perl data, or F<undef>.  F<write()> is auto-exported as F<L</WriteData>()>.

B<PARAMETERS>

When DATA is an object the Perl data to be compiled is defined by the F<-data> attribute. (When
F<-data> refers to another Rlist object, this other object is invoked.)  Otherwise DATA defines the
data to be compiled.

Optional OUTPUT defines where to compile to.  Defaults to the F<-output> attribute when DATA
defines some F<Data::Rlist> object.  Defines a filename to create, or some string-reference.  When
F<undef> writes to some anonymous string.

Optional L<OPTIONS|/Compile Options> arguments defines how to L<compile|/compile> text from DATA.  Defaults to the
F<-options> attribute when DATA is an object.  When uses F<L</compile_fast>()>, otherwise
F<L</compile>()>.

Optional HEADER is a reference to an array of strings that shall be printed literally at the top of
an output file. Defaults to the F<-header> attribute when DATA is an object.

B<RESULT>

When F<write()> creates a file it returns 0 for failure or 1 for success.  Otherwise it returns a
string reference.

B<EXAMPLES>

    $self = new Data::Rlist(-data => $thing, -output => $output);

    $self->write;   # Write into some file (if $output is a filename) or string (if $output is a
                    # string reference).

    Data::Rlist::write($thing, $output);    # dto. applying the functional interface

    new Data::Rlist(-data => $self)->write; # Another way to do it.

    print $self->make_string;               # Print $thing to stdout.
    print Data::Rlist::make_string($thing); # dto. applying the functional interface

=item F<write_csv(DATA[, OUTPUT, OPTIONS, COLUMNS, HEADER])>

=item F<write_conf(DATA[, OUTPUT, OPTIONS, HEADER])>

Write DATA as CSV to file or string OUTPUT.  These function automatically quote all fields that do
not look like numbers (see F<L</is_numeric>()>).

F<write_conf()> writes configuration files where each line contains a tagname, a separator and a
value.  F<write_csv()> uses a different default separator of C<",">, while F<write_conf()> uses C<"
= ">.

B<PARAMETERS>

See F<L</write>()> for the DATA and OUTPUT parameters, which are semantically equal.  From
L<OPTIONS|/Compile Options> is read the comma-separator (C<"separator">), the linefeed
(C<"eol_space">) and the numeric precision (C<"precision">).  COLUMNS, if specified, shall be an
array-ref defining the column names to be written as the first line.  All strings in the array-ref
HEADER are written as F<#>-comments before the data.

Like with F<L</write>()>, unless DATA refers to some F<Data::Rlist> object, it shall define the
data to be compiled.  But because of the limitations of CSV files the data may not be just any Perl
data.  It must be a reference to an array of array references, where each contained array defines
the fields, e.g.

    [ [ a, b, c ],      # line 1
      [ d, e, f, g ],   # line 2
        .
        .
    ]

Likewise, F<write_conf()> expects

    [ [ tag, value ],	# line 1
        .
        .
    ]

B<RESULT>

When F<write_csv()> creates a file it returns 0 for failure or 1 for success.  Otherwise it returns
a string reference.

B<EXAMPLES>

Functional interface:

    use Data::Rlist; # imports WriteCSV

    WriteCSV($thing, "foo.dat");

    WriteCSV($thing, "foo.dat", { separator => '; ' }, [qw/GBKNR VBKNR EL LaD LaD_V/]);

    WriteCSV($thing, \$target_string);

    $target_string_ref = WriteCSV($thing);

Object-oriented interface:

    $object = new Data::Rlist(-data => $thing, -output => "foo.dat",
                              -options => { separator => '; ' },
                              -columns => [qw/GBKNR VBKNR EL LaD LaD_V/]);
    $object->write_csv;     # Write $thing as CSV to foo.dat
    $object->write;         # Write $thing as Rlist to foo.dat

    $object->set(-output => \$target_string);
    $object->write_csv;     # Write $thing as CSV to $target_string

=item F<write_string(DATA[, OPTIONS])>

Like F<L</write>()> but always compiles to a new string to which it returns a reference.  In an
object this function does not use F<-output>, even when this attribute defines a string reference.
It also won't use F<-options>. Instead it uses the predefined options set L<C<"string">|/Predefined
Options> to render a very compact Rlist without newlines and here-docs.

=back

=head3 F<make_string()> and F<keelhaul()>

=over

=item F<make_string(DATA[, OPTIONS])>

Print Perl DATA to a string and return its value.  This function actually is an alias for

    ${Data::Rlist::write_string(DATA, OPTIONS)}

L<OPTIONS|/Compile Options> default to L<C<"default">|/Predefined Options>, which means that in an
object context F<make_string()> will never use the F<-options> attribute.

B<EXAMPLES>

    print "\n\$data: ", Data::Rlist::make_string($data);

    $self = new Data::Rlist(-data => $thing);

    print "\n\$thing: ", $self->make_string;

=item F<keelhaul(DATA[, OPTIONS])>

Do a deep copy of DATA according to L<OPTIONS|/Compile Options>.  DATA is some Perl data, or some F<L<Data::Rlist object|/new>()>.

F<keelhaul()> works by first compile DATA to text, then restoring the data from the text.  The text
had been carefully built according to certain L</Compile Options>. Hence, by "keelhauling data",
one can adjust the accuracy of numbers, break circular-references and drop F<\*foo{THING}>s.

B<EXAMPLES>

When F<keelhaul()> is called in an array context it also returns the text from which the copy had
been built:

    $deep_copy = Data::Rlist::keelhaul($thing);

    ($deep_copy, $rlist_text) = Data::Rlist::keelhaul($thing);

    $deep_copy = new Data::Rlist(-data => $thing)->keelhaul;

Bring all numbers in DATA to a certain accuracy:

    $thing = { foo => [.00057260, -1.6804e-4] };

    $deep_copy = Data::Rlist::keelhaul($thing, { precision => 4 });

which copies F<$thing> into

    { foo => [0.0006, -0.0002] }

All number scalars where rounded to 4 decimal places, so they're finally comparable as
floating-point numbers (see F<L</equal>()> for a discussion), One can also convert all floats to
integers:

    $self = Data::Rlist->new(-data => $thing);

    $deep_copy = $self->keelhaul({precision => 0});

B<NOTES>

It was said before that keelhauling is a working method to create a deep copy of Perl
data. F<keelhaul()> won't throw F<die> nor return an error, but be prepared for the following
effects:

=over

=item *

F<ARRAY>, F<HASH>, F<SCALAR> and F<REF> references were compiled, whether blessed or not.
Depending on the compile options F<CODE> references were called, deparsed back into their function
bodies, or dropped.

=item *

F<IO>, F<GLOB> and F<FORMAT> references have been converted into their plain typenames (see
F<L</compile>()>).

=item *

F<undef>'d array elements had been converted into the default scalar value C<"">.

=item *

Compile options are considered, such as implicit rounding of floats.

=item *

Anything deeper than F<$Data::Rlist::MaxDepth> is thrown away (again, see F<L</compile>()>).

=item *

Since compiling does not store type information, F<keelhaul()> will turn blessed references into
barbars again. No special methods to "freeze" and "thaw" an object is called before compiling or
after parsing it. Instead the copy is a copy made from what any object in a computer ultimately
consists of: strings and numbers.

=back

=item F<predefined_options([PREDEF-NAME])>

Get F<%Data::Rlist::PredefinedOptions{PREDEF-NAME}>.  PREDEF-NAME defaults to
L<C<"default">|/Predefined Options>, the options for writing files.

=item F<complete_options([OPTIONS[, BASIC-OPTIONS]])>

Completes L<OPTIONS|/Compile Options> with BASIC-OPTIONS: all pairs not already in OPTIONS are
copied from BASIC-OPTIONS (argument defaults to L<C<"default">|/Predefined Options>, the options
for writing files).  Both arguments define hashes or a L<predefined options name|/Predefined
Options>.

Returns a new hash of L<compile options|/Compile Options>.  (Even when OPTIONS defines a hash it is
copied into a new one.)

B<EXAMPLES>

    complete_options({ precision => 0 }, 'squeezed')

merges the predefined options for L<C<"squeezed">|/Predefined Options> text (no whitespace at all,
no here-docs, numbers are rounded to a precision of 6) with a numeric precision of 0.  This
converts all floats to integers.

	complete_options($them, { delimiter => '\s+' })

completes F<$them> by some other hash; but only keys not already in F<$them> are copied.  In fact,
the latter is suitable for configuration files; see also F<L<read_conf>()>.

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
        # $data is some Perl data or undef.  Reset package globals, validate $options, then compile
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
               "Random Lists (Rlist) data file (version $VERSION, see Data::Rlist on CPAN,",
               "\t\tand <http://www.visualco.de>).")),
             "",
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
        # $data is some Perl data or undef.  In case of undef returns 0.  When the file could not
        # be created, dies. Otherwise returns 1.
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
            join($separator, map { is_numeric($_)
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

If specified the function preprocesses the INPUT file using FILTER, before actually reading the
file.  Use the special value 1 for FILTER to select the default C preprocessor (precisely, F<gcc -E
-Wp,-C>).  FILTER-ARGS is an optional string of additional command-line arguments appended to
FILTER.  For example,

    my $foo = read("foo", 1, "-DEXTRA")

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
evaluating them.  But because of Perl's limited F<open()> function, which isn't able to open
arbitary pipes, the invocation of F<sed> requires a temporary file. The file is simply created by
appending C<".tmp"> to the pathname passed in INPUT.  F<L</lexln>()>, the function that feeds the
lexical scanner with lines, then converts F<##> back into comment lines.

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
non-recursive parser driven by the parser map F<%Data::Rlist::Rules>.  See also F<L</lex>()>.

=back

=head3 F<errors()>, F<broken()> and F<missing_input()>

=over

=item F<errors([SELF])>

Returns the number of syntax errors that occurred in the last call to F<L</parse>()>.  When called
as method (i.e. SELF is defined) returns the number of syntax errors that occured for the last time
an object had called F<L</read>()>.

=item F<broken([SELF])>

Return the number of times the last F<L</compile>()> crossed the zenith of
F<$Data::Rlist::MaxDepth>. When called as method returns the information for the last time an
object had called F<L</read>()>.

=item F<missing_input([SELF])>

Return true when the last call to F<L</parse>()> yielded F<undef> because there was nothing to
parse.  Otherwise, when F<parse()> returned F<undef>, this means there was some syntax error.
F<parse()> is called internally by F<L</read>()>.  When called as method returns the information
for the last time an object had called F<L</read>()>.

=back

=cut

our $g_re_lex_wsp = qr/^\s+/;
our $g_re_lex_num = qr/^($g_re_float_here)/; # number constant
our $g_re_lex_quoted_string = qr/^\"((?:\\[nrbftv\"\'\\]|\\[0-7]{3}|[^\"])*)\"/; # quoted string constant
our $g_re_lex_name = qr/^($g_re_name_here)/; # symbolic name without quotes
our $g_re_lex_quoted_name = qr/^"($g_re_name_here)"/; # symbolic name in quotes
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
            $Ln =~ s/\r*\n$//;  # One should really localize $/ in parse() and then chomp $Ln
                                # here. But I'm worried about the correct value for $/ to really
                                # make s/\r*\n$// happen.  Note: don't strip \s* (before \r)
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

sub errors {
    my $self = shift;
    if ($self) {
        my $a = $self->get(-parsing=>);
        return $a->[0] if ref $a;
        return 0;
    }
    $Errors                     # not called in object-context
}
sub broken(;$) {
    my $self = shift;
    if ($self) {
        my $a = $self->get(-parsing=>);
        return $a->[1] if ref $a;
        return 0;
    }
    $Broken                     # not called in object-context
}
sub missing_input { 
    my $self = shift;
    if ($self) {
        my $a = $self->get(-parsing=>);
        return $a->[2] if ref $a;
        return 0;
    }
    $MissingInput
}

=head3 F<compile()>

=over

=item F<compile(DATA[, OPTIONS, FH])>

Build Rlist from DATA.  DATA is a Perl scalar as number, string or reference.  When FH is defined
compile directly to this file and return 1.  Otherwise (FH is F<undef>) build a string and return a
reference to it.

=over

=item Reference-types F<SCALAR>, F<HASH>, F<ARRAY> and F<REF>.

Compiled into text, whether blessed or not.

=item Reference-types F<CODE>

How F<CODE> references are compiled depends on the C<"code_refs"> flag defined by L<OPTIONS|/Compile
Options>. Legal values are F<undef>, C<"call"> (the default) and C<"deparse">.

When C<"code-ref">'s value is F<undef> compiles C<"?CODE?">. A value of C<"call"> calls the sub and
compiles its result.  C<"deparse"> serializes the code using F<B::Deparse>, which reproduces the
Perl source of the sub. Note that it then makes sense to enable C<"here_docs">, because otherwise
the deparsed code will be in one string with LFs quoted as C<"\012">.

=item Reference-types F<GLOB>, F<IO> and F<FORMAT>

Reference-types that cannot be compiled are F<GLOB> (typeglob-refs), F<IO> (file- and directory
handles) and F<FORMAT>.  These are then converted into C<"?GLOB?">, C<"?IO?"> and
C<"?FORMAT?">.

=item Background: A Short Story of "Typeglobs"

Typeglobs are an idiosyncracy of Perl.  Perl uses a symbol table per package (namespace) to map
identifier names (like C<"foo"> without sigil) to values.  The symbol table is stored in the hash,
named like the package with two colons appended. The main symbol table's name is thus F<%main::>,
or F<%::>.

For example, in the name C<"foo"> in symbol tables is mapped to the F<typeglob> value F<*foo>.  The
typeglob object implements F<$foo> (the scalar value), F<@foo> (the list value), F<%foo> (the hash
value), F<&foo> (the code value) and F<foo> (the file handle or the format specifier).  All types
may coexist, so modifying F<$foo> won't change F<%foo>.  But F<*baz = *foo> overwrites, or creates,
the symbol table entry C<"baz">. (The value of C<"baz"> will be another F<typeglob> object.)

Typeglobs are F<variant>s that can store multiple concrete values. The sigil F<*> serves as
wildcard for the other sigils F<%>, F<@>, F<$> and F<&>. (Note: a F<sigil> is a symbol created for
a specific magical purpose; the name derives from the latin F<sigilum> = seal.)  So, the fancy-free
Perl primitives are F<\*foo>, a typeglob-ref, and F<\*::>, a typeglob-table-ref.

    \*foo;              # yields 'GLOB(0xNNN)'
    \*::;               # yields 'GLOB(0xNNN)'
    die unless \*foo == *foo{GLOB}; # never fires

F<\*foo> eventually is Perl's way to prove the existence of F<foo>, the symbol. F<*foo> is the
internal "proxy" that tells F<perl> what you really mean, at this moment, when you say C<"foo">.
In core this proxy is a hash-table, hence another way to say F<\*foo> is F<*foo{GLOB}>, which
eventually refers to C<"foo">'s incarnation as typeglob C<*foo>.

In other words: with typeglobs you reach the bedrock of F<perl>, where the spade bends back.  Note,
however, that after calling F<L</compile>()> typeglob-refs have gone up in smoke.

=item F<undef>

F<undef>'d values in arrays are compiled into the default Rlist C<"">.

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
                if ($v =~ /\n.+\n$/) {
                    # Here-docs enabled and $v qualifies: it has at least two newlines, and a final
                    # newline.  Now find a token that doesn't interfere with the text: first try
                    # "___", then "HERE", "HERE_0", "HERE_1" etc.

                    my @ln = split /\r*\n/, $v;
                    my $tok = '___';
                    while (1) {
                        last unless grep { /^$tok/ } @ln;
                        if ($tok =~ /\d$/) {
                            $tok++
                        } else {
                            $tok = $tok !~ 'HERE' ? 'HERE' : 'HERE_0'
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
					die $v unless $v =~ $g_re_name;
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

=item F<compile_fast(DATA)>

Assemble Rlist from Perl data DATA as fast as actually possible with pure Perl.  Reference-types
F<SCALAR>, F<HASH>, F<ARRAY> and F<REF> are compiled into text, whether blessed or not.  F<CODE>,
F<GLOB>, F<IO> and F<FORMAT> are compiled as C<"?CODE?">, C<"?IO?">, C<"?GLOB?"> and C<"?FORMAT?">.
F<undef> values in arrays are compiled into the default Rlist C<"">.

The main difference to F<L</compile>()> is that F<compile_fast()> considers no L<compile
options|/Compile Options>. Thus it cannot call code, implicitly round numbers etc., and cannot
detect recursively-defined data.

F<compile_fast()> returns a reference to the compiled string, which is a reference to a unique
package variable. Subsequent calls to F<compile_fast()> therefore reassign this variable.

=back

=cut

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
                # but produces much nicer results.  Note also that calling is_random_text is generally
                # faster than to quote always.

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
                            $R.= is_numeric($_) ? $_ : __quote($_)
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
                    $K = __quote($K) unless is_numeric($K);
                    $R.= $pref.chr(9).$K;
                    if (defined $V) {
                        $R.= ' => ';
                        if (ref $V) {
                            compile_Perl1($V);
                        } else {
                            $V = __quote($V) unless is_numeric($V);
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
            $R.= is_numeric($data) ? $$data : __quote($$data);
        } else {
            $R.= '"?'.reftype($data).'?"'
        }
        $Depth--;
    } elsif (defined $data) {   # number or string
        $R.= is_numeric($data) ? $data : __quote($data);
    } else {                    # undef
        $R.= DEFAULT;
    }
}

=head1 AUXILIARY FUNCTIONS

The utility functions in this section are generally useful when handling stringified data.  These
functions are either very fast, or smart, or both.  For example, F<L</quote>()>, F<L</unquote>()>,
F<L</escape>()> and F<L</unescape>()> internally use precompiled regexes and precomputed ASCII
tables; so employing these functions is probably faster then using own variants.

=head2 F<is_numeric()>, F<is_name()> and F<is_random_text()>

=over

=item F<is_integer(SCALAR-REF)>

Returns true when a scalar looks like an +/- integer constant.  The function applies the compiled
regex F<$Data::Rlist::g_re_integer>.

=item F<is_numeric(SCALAR-REF)>

Test for strings that look like numbers. F<is_numeric()> can be used to test whether a scalar looks
like a integer/float constant (numeric literal). The function applies the compiled regex
F<$Data::Rlist::g_re_float>.  Note that it doesn't match

- the IEEE 754 notations of Infinite and NaN,

- leading or trailing whitespace,

- lexical conventions such as the C<"0b"> (binary), C<"0"> (octal), C<"0x"> (hex) prefix to denote a
  number-base other than decimal, and

- Perls' "legible numbers", e.g. F<3.14_15_92>

See also

    perldoc -q "whether a scalar is a number"

=item F<is_name(SCALAR-REF)>

Test for symbolic names.  F<is_name()> can be used to test whether a scalar looks like a symbolic
name.  Such strings need not to be quoted.  Rlist defines symbolic names as a superset of C
identifier names:

    [a-zA-Z_0-9]                    # C/C++ character set for identifiers
    [a-zA-Z_0-9\-/\~:\.@]           # Rlist character set for symbolic names

    [a-zA-Z_][a-zA-Z_0-9]*                  # match C/C++ identifier
    [a-zA-Z_\-/\~:@][a-zA-Z_0-9\-/\~:\.@]*  # match Rlist symbolic name

For example, scoped/structured names such as F<std::foo>, F<msg.warnings>, F<--verbose>,
F<calculation-info> need not be quoted. (But if they're quoted their value is exactly the same.)
Note that F<is_name()> does not catch leading or trailing whitespace. Another restriction is that
C<"."> cannot be used as first character, since it could also begin a number.

=item F<is_random_text(SCALAR-REF)>

F<is_random_text()> returns true if the scalar is neither a symbolic name nor a number, nor is
double-quoted.  When this function returns true, then F<L</compile>()> and F<L</compile_fast>()>
would call F<L</quote>()> on the scalar.  In Rlists, all scalars need to be quoted, expect those
that are

- already quoted,

- look like C identifiers or L<symbolic names|/is_name>(),

- look like C L<number constants|/is_numeric>().

Warning: F<is_random_text()> makes no further test whether a string consists of characters that
actually require escaping. That is, it returns also true on strings that do not adhere to
7-bit-ASCII, by defining characters <32 and >127.

See also F<L</is_numeric>()> and F<L</is_name>()>.

=back

=cut

sub is_integer(\$) { ${$_[0]} =~ $g_re_integer ? 1 : 0 }
sub is_numeric(\$) { ${$_[0]} =~ $g_re_float ? 1 : 0 }
sub is_name(\$) { ${$_[0]} =~ $g_re_name ? 1 : 0 }
sub is_random_text(\$) { ${$_[0]} =~ $g_re_value ? 0 : 1 }

=head2 F<quote()>, F<escape()> and F<unhere()>

=over

=item F<quote(TEXT)>

=item F<escape(TEXT)>

Converts TEXT into 7-bit-ASCII.  All characters not in the set of the 95 printable ASCII characters
are F<escape>d.  The difference between the two functions is that F<quote()> additionally places
TEXT into double-quotes.

The following ASCII codes will be converted to escaped octal numbers, i.e. 3 digits prefixed by a
slash:

    0x00 to 0x1F
    0x80 to 0xFF
    " ' \

For example, F<quote(qq'"FrE<uuml>her Mittag\n"')> returns C<"\"Fr\374her Mittag\012\"">, while
F<escape()> returns C<\"Fr\374her Mittag\012\">

=item F<maybe_quote(TEXT)>

Return F<quote(TEXT)> if F<L</is_random_text(TEXT)>>; otherwise (TEXT defines a symbolic name or
number) return TEXT.

=item F<maybe_unquote(TEXT)>

Return F<unquote(TEXT)> when the first character of TEXT is C<">; otherwise returns TEXT.

=item F<unquote(TEXT)>

=item F<unescape(TEXT)>

Reverses F<L</quote>()> and F<L</escape>()>.

=item F<unhere(HERE-DOC-STRING[, COLUMNS, FIRSTTAB, DEFAULTTAB])>

HERE-DOC-STRING shall be a L<here-document|/Here Documents>. The function checks whether each line
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

    $g_re_escape_seq = qr/\\([0-7]{1,3}|["'\\])/;
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

    # Finally add \ " ' into the tables, which spares another s// call in escape and unescape for
    # them. (These are actually one of the 95 printables 0x20..0x7F.) The leading \ is alredy
    # matched by $g_re_escape_seq.

    $g_nonprintables_escaped{chr(34)} = qq(\\"); # " => \"
    $g_nonprintables_escaped{chr(39)} = qq(\\'); # ' => \'

    $g_escaped_nonprintables{chr(34)} = chr(34);
    $g_escaped_nonprintables{chr(39)} = chr(39);
    $g_escaped_nonprintables{chr(92)} = chr(92);
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
    # The \ => \\ (ASCII 92) conversion has to happen first because the below s// will intersperse
    # more backslashes.

    my $s = shift;
    return "" unless defined $s;
    $s =~ s/\\/\\\\/g;
    $s =~ s/$g_re_nonprintable/$g_nonprintables_escaped{$1}/gos;
    $s
}

sub unescape($) {
    my $s = shift;
    # eg. \374 => ü, \" => " and \\ => \
    $s =~ s/$g_re_escape_seq/$g_escaped_nonprintables{$1}/gos;
    #$s =~ s/\\\\/\\/g;
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

=head2 F<split_quoted()>

=over

=item F<split_quoted(INPUT[, DELIMITER])>

=item F<parse_quoted(INPUT[, DELIMITER])>

Divide the string INPUT into a list of strings.  DELIMITER is a regular expression specifying where
to split (default: C<'\s+'>).  The function won't split at DELIMITERs inside quotes, or which are
backslashed.  For example, to split INPUT at commas use C<'\s*,\s*'>.

F<parse_quoted()> works like F<split_quoted()> but additionally removes all quotes and backslashes
from the splitted fields.

Both functions effectively simplify the interface of F<Text::ParseWords>.  In an array context they
return a list of substrings, otherwise the count of substrings. An empty array is returned in case
of unbalanced C<"> quotes, e.g.  F<split_quoted(C<foo,"bar>)>.

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
F<('foo','bar','')> and hence can be used to to split a large string of unF<cho(m)p>'d input lines
into words:

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

F<parse_quoted()>:

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

Split a large string F<$soup> (mnemonic: possibly "slurped" from a file) into lines, at LF or
CR+LF:

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

Note, however, that the F<L</read_csv>()> function already reads F<.csv>-file perfectly well.

A nice way to make sure what F<split_quoted()> and F<parse_quoted()> return is using
F<deep_compare()>.  For example, the following code shall never die:

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

=head2 F<equal()> and F<round()>

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
F<L</round(42)>> does not return 42.000000, and F<round(0.12)> returns 0.12, not 0.120000.  This
behavior is especially welcome when scientific notation was selected.  For example, note that

    sprintf("%.6g\n", 2006073104)

yields 2.00607e+09, which looses digits.

B<MACHINE ACCURACY>

One needs F<L</equal>()> to compare floats because IEEE 754 single- and double precision
implementations are not absolute - in contrast to the numbers they represent.  In all machines
non-integer numbers are only an approximation to the numeric truth.  In other words, they're not
commutative! For example, given two floats F<a> and F<b>, the result of F<a+b> might be different
than that of F<b+a>.

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
    my $a = shift; return $a if is_integer($a);
    my $prec = shift; $prec = 6 unless defined $prec;
    return sprintf("%.${prec}g", $a) if $RoundScientific;
    return sprintf("%.${prec}f", $a);
}

=head2 F<deep_compare()>

=over

=item F<deep_compare(A, B[, PRECISION, PRINT])>

Compare and analyze two numbers, strings or references. Generates a log (stack of messages)
describing exactly all unequal data.  Hence, for some perl data F<$a> and F<$b> one can assert:

    croak "$a differs from $b" if deep_compare($a, $b);

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
the comparision for all other elements in A and B.  Hence the structures are identical in all other
elements.

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

=head2 F<fork_and_wait()>, F<synthesize_pathname()>

=over

=item F<fork_and_wait(PROGRAM[, ARGS...])>

Forks a process and waits for completion.  The function will extract the exit-code, test whether
the process died and prints status messages on F<stderr>.  F<fork_and_wait()> hence is a handy
wrapper around the built-in F<system()> and F<exec()> functions.  Returns an array of three values:

    ($exit_code, $failed, $coredump)

F<$exit_code> is -1 when the program failed to execute (e.g. it wasn't found or the current user
has insufficient rights).  Otherwise F<$exit_code> is between 0 and 255.  When the program died on
receipt of a signal (like F<SIGINT> or F<SIGQUIT>) then F<$signal> stores it. When F<$coredump> is
true the program died and a F<core> file was written.  Note that some systems store F<core>s
somewhere else than in the programs' working directory.

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
                    $s =~ s/^"(.+)"$/$1/;
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
                    $s =~ s/^[\-\s]+|[\-\s]+$//o;
                    $s
                } @s
        )
}

=head1 IMPORTED FUNCTIONS

=head2 Explicit Imports

Three tags are available that import function sets. These are utility functions usable also
separately from F<Data::Rlist>.

=over

=item F<:floats>

Imports F<L</equal>()>, F<L</round>()> and F<L</is_numeric>()>.

=item F<:strings>

Imports F<L</maybe_quote>()>, F<L</quote>()>, F<L</escape>()>, F<L</unquote>()>, F<L</unescape>()>,
F<L</unhere>()>, F<L</is_random_text>()>, F<L</is_numeric>()>, F<L</is_name>()>, F<L</split_quoted>()>, and
F<L</parse_quoted>()>.

=item F<:options>

Imports F<L</predefined_options>()> and F<L</complete_options>()>.

=item F<:aux>

Imports F<L</deep_compare>()>, F<L</fork_and_wait>()> and F<L</synthesize_pathname>()>.

=back

B<EXAMPLES>

    use Data::Rlist qw/:floats :strings/;

=head2 Automatic Imports

These functions are implicitly imported into the callers symbol table by the package: F<ReadCSV()>,
F<ReadData()>, F<WriteData()>, F<PrintData()>, F<OutlineData()>, F<StringizeData()>,
F<SqueezeData()>, F<KeelhaulData()> and F<CompareData()>.

You may say F<require Data::Rlist> (instead of F<use Data::Rlist>) to prohibit auto-import.  See
also L<perlmod>.

=head2 Importing when F<Rlist.pm> is installed locally

Installing CPAN packages usually requires administrator privileges.  In case you don't have them,
another way is to the F<Rlist.pm> file e.g. into F<.> or F<~/bin>:

    BEGIN {
        $0 =~ /[^\/]+$/;
        push @INC, $`||'.', "$ENV{HOME}/bin";
        require Rlist;
        Data::Rlist->import();
        Data::Rlist->import(qw/:floats :strings/);
    }

This code finds F<Rlist.pm> also in F<.> and F<~/bin>.  It then calls the F<Exporter> manually.

=head2 F<ReadCSV()> and F<ReadData()>

=over

=item F<ReadCSV(INPUT[, OPTIONS, FILTER, FILTER-ARGS])>

Another way to call F<Data::Rlist::L</read_csv>()>.

=item F<ReadConf(INPUT[, OPTIONS, FILTER, FILTER-ARGS])>

Another way to call F<Data::Rlist::L</read_conf>()>.

=item F<ReadData(INPUT[, FILTER, FILTER-ARGS])>

Another way to call F<Data::Rlist::L</read>()>.

=back

=head2 F<WriteCSV()> and F<WriteData()>

=over

=item F<WriteCSV(DATA[, OUTPUT, OPTIONS, COLUMNS, HEADER])>

Another way to call F<Data::Rlist::L</write_csv>()>.

=item F<WriteConf(DATA[, OUTPUT, OPTIONS, HEADER])>

Another way to call F<Data::Rlist::L</write_conf>()>.

=item F<WriteData(DATA[, OUTPUT, OPTIONS, HEADER])>

Another way to call F<Data::Rlist::L</write>()>.

=back

=head2 F<OutlineData()>, F<StringizeData()> and F<SqueezeData()>

=over

=item F<OutlineData(DATA[, OPTIONS])>

=item F<StringizeData(DATA[, OPTIONS])>

=item F<SqueezeData(DATA[, OPTIONS])>

Another way to call F<Data::Rlist::L</make_string>()>.

F<OutlineData()> applies the predefined L<C<"outlined">|/Predefined Options> L<options set|/Compile
Options>, while F<StringizeData()> applies L<C<"string">|/Predefined Options> and F<SqueezeData>()
L<C<"squeezed">|/Predefined Options>.  When specified, L<OPTIONS|/Compile Options> are merged into
the predefined set.  For example,

    print "\n\$thing: ", OutlineData($thing, { precision => 12 });

L<rounds|/round>() all numbers in F<$thing> to 12 digits.

=item F<PrintData(DATA[, OPTIONS])>

Another way to say

	print OutlineData(DATA, OPTIONS);

=back

=head2 F<KeelhaulData()> and F<CompareData()>

=over

=item F<KeelhaulData(DATA[, OPTIONS])>

Calls F<L</keelhaul>()>.  For example,

    use Data::Rlist;
        .
        .
    my($copy, $as_text) = KeelhaulData($thing);

=item F<CompareData(A, B[, PRECISION, PRINT_TO_STDOUT])>

Calls F<L</deep_compare>()>.

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

=head1 HISTORY / NOTES

The F<Random Lists> (Rlist) syntax is inspired by NeXTSTEP's F<Property Lists>.  Rlist is simpler,
more readable and more portable.  The Perl, C and C++ implementations are fast, table and free.
Markus Felten, with whom I worked a few month in a project at Deutsche Bank, Frankfurt in summer
1998, arrested my attention on Property lists.  He had implemented a Perl variant of it
(F<L</http://search.cpan.org/search?dist=Data-PropertyList>>).

The term "Random" underlines the fact that the language

=over

=item *

has only four primitive data types;

=item *

the basic building block is a list (sequential or associative), and this list can be combined F<at
random> with other lists.

=back

Hence the term "Random" does not mean F<aimless> or F<accidental>.  F<Random Lists> are F<arbitrary
lists>.  Application data can be made portable (due to 7-bit-ASCII) and persistent by dealing
arbitrarily with lists of numbers and strings.  Like with CSV the lexical overhead Rlist imposes is
minimal: files are merely data.  Also, files are viewable/editable by text editors.  Users then
shall not be dazzled by language gizmo's.

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
can be simply F<eval>'d. Rlists are not Perl-syntax and need to be parsed carefully.  But Rlist
text is portable (7-bit-ASCII with non-printables escaped) and implementations exist for other
programming languages, namely C++ which uses a fast flex/bison-parser.

While reading F<Data::Dumper>-generated files back is generally faster than F<L</read>()>.  For
example, with F<$Data::Dumper::Useqq> enabled, it was observed that F<Data::Dumper> renders output
three to four times slower than F<L</compile>()>

Consider also that F<Data::Rlist> tests for any scalar whether it is numeric or not (see
F<L</is_random_text>()>), where F<Data::Dumper> simply quotes any number and string.  So
F<Data::Rlist> is able to implicitly round floats to a certain precision, making them finally
comparable (see F<L</round>()> for more information).

F<Data::Rlist> generates much smaller files: with the default F<$Data::Dumper::Indent> of 2 Rlist
output is just 15-20% of the size the F<Data::Dumper> package prints (for the same data).  The
simple reason: F<Data::Dumper> recklessly uses many whitespaces (blanks) instead of horizontal
tabulators; this unnecessarily blows up file sizes.

=head1 DEPENDENCIES

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

=head1 BUGS AND DEFICIENCIES

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

To increase compilation speed, a string F<$s> is only F<L</quote>()>d when
F<$s!~$Data::Rlist::g_re_value>. (Note that this regex is applied also by F<L</is_random_text>()>.)
The regex checks wether F<$s> begins with C<">, or defines a symbolic name or a number.  But when
the 1st character of F<$s> is C<">, no further test are made whether characters in the actually
require escaping.  It is then believed that the string adheres to 7-bit-ASCII.  If this isn't the
case it might not be read back correctly.  See also F<L</is_name>()>, F<L</is_integer>()> and
F<L</is_numeric>()>.

=back

=head1 AUTHOR

Andreas Spindler, F<rlist@visualco.de>

=head1 COPYRIGHT AND LICENSE

Copyright 1998-2007 Andreas Spindler

Maintained at CPAN and L</http://www.visualco.de>

See L<http://search.cpan.org/~aspindler>.

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
