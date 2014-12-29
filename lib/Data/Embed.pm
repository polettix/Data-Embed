package Data::Embed;

# ABSTRACT: embed arbitrary data in a file

use strict;
use warnings;
use English qw< -no_match_vars >;
use Exporter qw< import >;
use Log::Log4perl::Tiny qw< :easy :dead_if_first >;

our @EXPORT_OK = qw< writer reader embed embedded >;
our @EXPORT = ();
our %EXPORT_TAGS = (
   all => \@EXPORT_OK,
   reading => [ qw< reader embedded > ],
   writing => [ qw< writer embed    > ],
);

=head1 FUNCTIONS

=head2 B<< embed >>

Embed new data inside a container file. The calling syntax is
as follows:

   embed($container, $hashref); # OR
   embed($container, %keyvalue_pairs);

The C<$container> parameter is the target file where the new data
will be inserted.

Additional parameters can be passed as key-value pairs either
directly or through a hash reference. The following keys are
supported:

=over

=item C<name>

the name to associate to the section, optionally. If missing it will
be set to the empty string

=item C<fh>

the filehandle from where data should be taken. The filehandle will be
exausted starting from its current position

=item C<filename>

a filename or a reference to a scalar where data will be read from

=item c<data>

a scalar from where data will be read. If you have a huge amount of
data, it's better to use the C<filename> key above passing a reference
to the scalar holding the data.

=back

Options C<fh>, C<filename> and C<data> are exclusive and will be considered
in the order above (first come, first served).

This function does not return anything.

=head2 B<< embedded >>

Get a list of the embedded files inside a target container. The calling
syntax is as follows:

   my $arrayref = embedded($container); # scalar context, OR
   my @files    = embedded($container); # list context

The only input parameter is the C<$container> to use as input. It can
be either a real filename, or a filehandle.

Depending on the context, a list will be returned (in list context) or
an array reference holding the list.

Whatever the context, each item in the list is a L<Data::Embed::File>
object that you can use to access the embedded file data (most notably,
you'll be probably using its C<contents> or C<fh> methods).

=head2 B<< writer >>

This is a convenience wrapper around the constructor for
L<Data::Embed::Writer>.

=head2 B<< reader >>

This is a convenience wrapper around the constructor for
L<Data::Embed::Reader>.

=cut

sub writer {
   require Data::Embed::Writer;
   return Data::Embed::Writer->new(@_);
}

sub reader {
   require Data::Embed::Reader;
   return Data::Embed::Reader->new(@_);
}

sub embed {
   my $writer = writer(shift)
      or LOGCROAK 'could not get the writer object';
   return $writer->add(@_);
}

sub embedded {
   my $reader = reader(shift)
      or LOGCROAK 'could not get the writer object';
   return $reader->files();
}

1;
__END__
