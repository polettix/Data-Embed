package Data::Embed::File;

# ABSTRACT: embed arbitrary data in a file

use strict;
use warnings;
use English qw< -no_match_vars >;
use IO::Slice;
use Fcntl qw< :seek >;
use Log::Log4perl::Tiny qw< :easy >;

=head1 METHODS

=head2 B<< new >>

Constructor. It will act lazily, just storing the input data
for later usage by other methods, providing validation.

Input data can be provided as key-value pairs of through a
reference to a hash.

For proper functioning of the object, the following keys
should be provided:

=over

=item C<< fh >>

a filehandle for the stream where the data are contained

=item C<< filename >>

the name of the file where the data are. This parameter is
optional if C<fh> above is already provided.

=item C<< offset >>

the offset within the stream where the real data for this
file begins. C<0> means the very beginning of the file.

=item C<< length >>

the length of the data belonging to this C<File>.

=back

=cut

sub new {
   my $package = shift;
   my $self = {(scalar(@_) && ref($_[0])) ? %{$_[0]} : @_};
   for my $feature (qw< offset length >) {
      LOGCROAK "$package new(): missing required field $feature"
        unless defined($self->{$feature})
        && $self->{$feature} =~ m{\A\d+\z}mxs;
   }
   LOGDIE "$package new(): either filename or fh are required"
     unless defined($self->{fh}) || defined($self->{filename});
   return bless $self, $package;
} ## end sub new

=head2 B<< fh >>

Get a filehandle suitable for accessing the embedded file. It provides
back a filehandle through L<IO::Slice>, providing the illusion of
working on a file per-se instead of a slice inside a bigger file.

=cut

sub fh {
   my $self = shift;
   if (!exists $self->{slicefh}) {
      my %args = map { $_ => $self->{$_} }
        grep { defined $self->{$_} } qw< fh filename offset length >;
      $self->{slicefh} = IO::Slice->new(%args);
   }
   return $self->{slicefh};
} ## end sub fh

=head2 B<< contents >>

Convenience method to slurp the whole contents of the embedded file
in one single shot. It always provides the full contents, independently
of whether data had been read before, although it restores the filehandle
to the previous position.

=cut

sub contents {
   my $self = shift;
   my $fh   = $self->fh();
   my $current = tell $fh;
   seek $fh, 0, SEEK_SET;

   local $/ = wantarray() ? $/ : undef;
   my @retval = <$fh>;
   seek $fh, $current, SEEK_SET;
   return @retval if wantarray();
   return $retval[0];
} ## end sub contents

=head2 B<< name >>

Get the name associated to the file, whatever it is. L<Data::Embed::Reader>
sets it from what is read in the index file

=cut

sub name { return shift->{name}; }

1;
__END__

=head1 DESCRIPTION

Accessor class for representing an embedded file (for reading).
