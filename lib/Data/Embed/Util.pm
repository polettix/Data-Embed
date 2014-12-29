package Data::Embed::Util;

# ABSTRACT: embed arbitrary data in a file - utilities

use strict;
use warnings;
use English qw< -no_match_vars >;

use Exporter qw< import >;
our @EXPORT_OK = qw< STARTER TERMINATOR escape unescape >;
our @EXPORT = (); # export nothing by default
our %EXPORT_TAGS = (
   all => [qw< STARTER TERMINATOR escape unescape >],
   escaping => [qw< escape unescape >],
   constants => [qw< STARTER TERMINATOR >],
);

=head1 FUNCTIONS

All these functions are 

=head2 B<< STARTER >>


=cut

use constant STARTER    => "Data::Embed/index/begin\n";
use constant TERMINATOR => "Data::Embed/index/end\n";

sub escape {
   my $text = shift;
   $text =~ s{([^\w.-])}{'%' . sprintf('%02x', ord $1)}egmxs,
   return $text;
}

sub unescape {
   my $text = shift;
   $text =~ s{%(..)}{chr(hex($1))}egmxs;
   return $text;
}



1;
__END__

=head1 DESCRIPTION

Accessor class for representing an embedded file (for reading).
