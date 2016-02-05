# NAME

Data::Embed - embed arbitrary data in a file

# VERSION

This document describes Data::Embed version 0.3\_02.

# SYNOPSIS

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

# DESCRIPTION

This module allows you to manage embedding data at the end of other
files, providing both means for embedding the data (["embed"](#embed) and
["writer"](#writer)) and accessing them (["embedded"](#embedded) and ["reader"](#reader)).

How can this be helpful? For example, suppose that you want to bring
some data along with your perl script, some of which might be binary
(e.g. an image, or a tar archive), you can embed these data inside the
perl and then retrieve them. For example, this can be the basis for an
installer.

For embedding data, you can use the ["embed"](#embed) function. See the relevant
documentation or the examples in the ["SYNOPSYS"](#synopsys) to use it properly.

For extracting the embedded data, you can use the ["embedded"](#embedded) function
and access each embedded file as a [Data::Embed::File](https://metacpan.org/pod/Data::Embed::File) object. You can
then use its methods `contents` for accessing the whole data, or get a
filehandle through `fh` and avoid getting the whole data in memory at
once.

Note: the filehandle provided by the `fh` method of
[Data::Embed::File](https://metacpan.org/pod/Data::Embed::File) is actually a [IO::Slice](https://metacpan.org/pod/IO::Slice) object, so it might not
support all the functions/methods of a regular filehandle.

You can also access the lower level interface through the two functions
["reader"](#reader) and ["writer"](#writer). See the documentation for
[Data::Embed::Reader](https://metacpan.org/pod/Data::Embed::Reader) and [Data::Embed::Writer](https://metacpan.org/pod/Data::Embed::Writer).

# FUNCTIONS

## **embed**

    embed($hashref); # OR
    embed(%keyvalue_pairs);

Embed new data inside a container file.

Parameters can be passed as key-value pairs either directly or through a
hash reference. The following keys are supported:

- `container`

    shortcut to specifying the same input and output, i.e. the value will be
    replicated both on the `input` and `output` keys below. Caller still
    has to ensure that the two are compatible. Provision of a filehandle is
    currently not supported.

- `input`

    any previous container file to use as base for the generated container.
    If missing, no previous data will be considered (like starting from an
    empty file). Can be:

    - the `-` string in a plain scalar, in which case standard input is
    considered
    - any other string in a plain scalar, considered to be a file name
    - a plain reference to a scalar, considered to hold the input data
    - something that supports the filehandle interface for reading

- `output`

    the target container for the newly generated archive. Might be the same
    as the input or different; in the latter case, the input will be copied
    over the output, apart from the bits regarding the management of the
    inclusions. Can be:

    - missing/undefined or the `-` string in a plain scalar, in which case
    standard output is used
    - any other string in a plain scalar, considered to be a file name
    - a plain reference to a scalar, considered to be the target scalar to
    hold the data
    - something that supports the filehandle interface for printing. You
    should not provide the same filehandle for both input and output, even
    if you opened it in read-write mode. This limitation might be removed in
    the future.

- `name`

    the name to associate to the section, optionally. If missing it will be
    set to the empty string

- `fh`

    the filehandle from where data should be taken. The filehandle will be
    exausted starting from its current position

- `filename`

    a filename or a reference to a scalar where data will be read from

- `data`

    a scalar from where data will be read. If you have a huge amount of
    data, it's better to use the `filename` key above passing a reference
    to the scalar holding the data.

Options `fh`, `filename` and `data` are exclusive and will be
considered in the order above (first come, first served).

This function does not return anything.

## **embedded**

Get a list of the embedded files inside a target container. The calling
syntax is as follows:

    my $arrayref = embedded($container); # scalar context, OR
    my @files    = embedded($container); # list context

The only input parameter is the `$container` to use as input. It can be
either a real filename, or a filehandle.

Depending on the context, a list will be returned (in list context) or
an array reference holding the list.

Whatever the context, each item in the list is a [Data::Embed::File](https://metacpan.org/pod/Data::Embed::File)
object that you can use to access the embedded file data (most notably,
you'll be probably using its `contents` or `fh` methods).

## **generate\_module\_from\_file**

    # when %args includes details for an output channel
    generate_module_from_file(%args);

    # in case no output is provided in %args:
    my $text = generate_module_from_file(%args);

Generate a module's file contents from a file. The module contains code
of a package that has code to read the included data. Arguments are:

- package

    the name of the package that will be put into the module. This is a
    mandatory parameter.

- output

    the output channel. If not present, the output will be provided as a
    string returned by the function, otherwise you can provide

    - a filehandle where the output will be printed
    - a reference to a scalar (it will be filled with the contents)
    - the `-` string, in which case the output will be printed
    to STDOUT
    - a filename

- output\_from\_package

    if this key is present and true, the `output` parameters is overridden
    and generated automatically from the package name provided in key
    `package`. The generated file will assume that the file is contained in
    the _normal_ path under a `lib` directory, e.g. if the package name is
    `Some::Module` then the generated filename will be
    `lib/Some/Module.pm`.

- fh

    a filehandle where data will be read from

- filename

    the input will be taken from the provided filename

- dataref

    the input will be taken from the scalar pointed by the
    reference

- data

    the input is taken from the scalar provided with the data key

Input keys are `fh`, `filename`, `dataref` and `data`. In case
multiple of them are present, they will be considered in the order
specified.

## **reader**

This is a convenience wrapper around the constructor for
[Data::Embed::Reader](https://metacpan.org/pod/Data::Embed::Reader).

## **reassemble**

    # when %args includes details for an output channel
    reassemble(%args);

Reassemble a target container fitting new input sequence. The available
arguments are:

- sequence

    the sequence of items that have to be embedded. Each item can be:

    - a [Data::Embed::File](https://metacpan.org/pod/Data::Embed::File) (e.g. coming from what you read from some other
    file)
    - a reference to a hash whose contents is compatible with what expected by
    [Data::Embed::Writer::add](https://metacpan.org/pod/Data::Embed::Writer::add).

- target

    the target container. It can be:

    - a _filehandle_
    - a _filename_ (including `-`, that does what you mean)
    - a _reference to a scalar_

    If the file or reference to a scalar are used, it will make sure to
    avoid clobbering. In particular, the _prefix_ data (i.e. data that is
    not part of the list of files) will be preserved.

## **writer**

This is a convenience wrapper around the constructor for
[Data::Embed::Writer](https://metacpan.org/pod/Data::Embed::Writer).

# BUGS AND LIMITATIONS

Report bugs either through RT or GitHub (patches welcome).

Passing the same filehandle for both `input` and `output` in ["embed"](#embed)
is not supported. This applies to `container` too.

# SEE ALSO

[Data::Section](https://metacpan.org/pod/Data::Section) covers a somehow similar need but differently. In
particular, you should look at it if you want to be able to modify the
data you want to embed directly, e.g. if you are embedding some textual
templates that you want to tweak.

# AUTHOR

Flavio Poletti <polettix@cpan.org>

# COPYRIGHT AND LICENSE

Copyright (C) 2014-2016 by Flavio Poletti <polettix@cpan.org>

This module is free software. You can redistribute it and/or modify it
under the terms of the Artistic License 2.0.

This program is distributed in the hope that it will be useful, but
without any warranty; without even the implied warranty of
merchantability or fitness for a particular purpose.
