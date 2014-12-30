NAME
====

Data::Embed - embed arbitrary data in a file

SYNOPSYS
========

    use Data::Embed qw< embed embedded >;

    # this is the file where thing will be embedded, at the end
    my $container = '/path/to/some/file';

    # first of all we embed an external file
    my $datafile  = '/path/to/data.tar.gz';
    embed($container, name => 'data.tar.gz', filename => $datafile);

    # we can also embed some data, directly
    use Data::Dumper;
    my $conf = { ... };
    embed($container, name => 'config.yml', data => Dumper($conf));

    # if the data is in a scalar but it's huge, use filename and
    # pass a reference to the scalar so no copy will happen
    my $huge_png = ...;
    embed($container, name => 'image.png', filename => \$huge_png);

    # to retrieve the stuff, use embedded()
    my @files = embedded($container);

    # each item in @files is a Data::Embed::File object

    # get whole contents of file
    my $config_text = $files[1]->contents();

    # otherwise, you can get a filehandle and use it, e.g. to
    # dump it on standard output
    my $data_fh = $files[0]->fh();
    binmode STDOUT;
    print {*STDOUT} <$data_fh>;

    # or save the file back, using the available name
    open my $ofh, '>:raw', $file[2]->name(); # well, do your checks!
    my $ifh = $files[2]->fh();
    while (! eof $ifh) {
       read $ifh, my $buffer, 4096
          or last; # do proper checks in production!
       print {$ofh} $buffer;
    }


ALL THE REST
============

Want to know more? [See the module's documentation](http://search.cpan.org/perldoc?Data::Embed) to figure out
all the bells and whistles of this module!

Want to install the latest release? [Go fetch it on CPAN](http://search.cpan.org/dist/Data-Embed/).

Want to contribute? [Fork it on GitHub](https://github.com/polettix/Data-Embed).

That's all folks!

