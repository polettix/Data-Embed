package Data::Embed;

use strict;
use warnings;
use English qw< -no_match_vars >;
use Exporter qw< import >;
{ our $VERSION = '0.22'; }
use Log::Log4perl::Tiny qw< :easy :dead_if_first >;

our @EXPORT_OK =
  qw< writer reader embed embedded generate_module_from_file >;
our @EXPORT      = ();
our %EXPORT_TAGS = (
   all     => \@EXPORT_OK,
   reading => [qw< reader embedded >],
   writing => [qw< writer embed    generate_module_from_file >],
);

sub writer {
   require Data::Embed::Writer;
   return Data::Embed::Writer->new(@_);
}

sub reader {
   require Data::Embed::Reader;
   return Data::Embed::Reader->new(@_);
}

sub embed {
   my %args = (@_ && ref($_[0])) ? %{$_[0]} : @_;

   my %constructor_args =
     map { $_ => delete $args{$_} } qw< input output >;
   $constructor_args{input} = $constructor_args{output} =
     delete $args{container}
     if exists $args{container};
   my $writer = writer(%constructor_args)
     or LOGCROAK 'could not get the writer object';

   return $writer->add(%args);
} ## end sub embed

sub embedded {
   my $reader = reader(shift)
     or LOGCROAK 'could not get the writer object';
   return $reader->files();
}

sub generate_module_from_file {
   require Data::Embed::OneFileAsModule;
   goto &Data::Embed::OneFileAsModule::generate_module_from_file;
}

1;
