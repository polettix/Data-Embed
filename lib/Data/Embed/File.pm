package Data::Embed::File;

# ABSTRACT: embed arbitrary data in a file

use strict;
use warnings;
use English qw< -no_match_vars >;
use IO::Slice;
use Fcntl qw< :seek >;
use Log::Log4perl::Tiny qw< :easy >;

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

sub fh {
   my $self = shift;
   if (!exists $self->{slicefh}) {
      my %args = map { $_ => $self->{$_} }
        grep { defined $self->{$_} } qw< fh filename offset length >;
      $self->{slicefh} = IO::Slice->new(%args);
   }
   return $self->{slicefh};
} ## end sub fh

sub contents {
   my $self    = shift;
   my $fh      = $self->fh();
   my $current = tell $fh;
   seek $fh, 0, SEEK_SET;

   local $/ = wantarray() ? $/ : undef;
   my @retval = <$fh>;
   seek $fh, $current, SEEK_SET;
   return @retval if wantarray();
   return $retval[0];
} ## end sub contents

sub name { return shift->{name}; }

1;
