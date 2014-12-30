use Test::More tests => 10;

use strict;
use Data::Embed qw< embed embedded >;
use File::Basename qw< dirname >;
use lib dirname(__FILE__);
use DataEmbedTestUtil qw< read_file write_file >;

my $prefix   = "something before\n";
my $sample1  = "This is some data\n";
my $sample2  = join '', "binary data:\n", map { chr($_) } 0 .. 255;
my $contents = join "\n", "$prefix$sample1\n", "$sample2\n",
  'Data::Embed/index/begin',
  '18 some%20thing',
  '269 anoth%25%25er',
  "Data::Embed/index/end\n";
my $testfile = __FILE__ . '.test1';

{  # embed
   write_file($testfile, $prefix);
   embed($testfile, data => $sample1, name => 'some thing');
   embed($testfile, data => $sample2, name => 'anoth%%er');
   my $generated = read_file($testfile);
   is $generated, $contents, 'generated file is as expected';
}

{  # embedded
   write_file($testfile, $contents);
   my @files = embedded($testfile);
   is scalar(@files), 2, 'number of embedded files';

   my ($f1, $f2) = @files;
   isa_ok $f1, 'Data::Embed::File';
   is $f1->{name}, 'some thing', 'name of first file';
   my $contents1 = $f1->contents();
   is $contents1, $sample1, 'contents of first embedded file, via contents()';

   isa_ok $f2, 'Data::Embed::File';
   is $f2->{name}, 'anoth%%er', 'name of second file';
   my $fh = $f2->fh();
   isa_ok $fh, 'GLOB', 'fh() output';
   my $first_line = <$fh>;
   is $first_line, "binary data:\n", 'first line of second file';
   my $rest = do { local $/; <$fh> };
   is $first_line . $rest, $sample2, 'contents of second file';
}
