NAME
====

Data::Embed - embed arbitrary data in a file

SYNOPSIS
========

DESIGN
======

Index of sections is completely accessible at the end.
Last line contains the number of bytes this index is compound of.

Index is as follows:

Items list, one per line


    start of data section --> offset X in file (start from 0)
    end of data section   --> offset Y in file (start from 0
    newline               --> Y + 1
    start of index        --> Y + 2
    end of index (always newline) --> Y + k
    Data::Embed[k,Y-X]<newline>

    15 00-
    14 01-
    13 02-
    12 03D
    11 04D
    10 05D
    09 06D  => data_length = 4
    08 07\n separator, not part of D
    07 08I
    06 09I
    05 10\n (part of I)  => index_length = 3
    04 11[
    03 12?
    02 13]
    01 14\n (part of lastline) => lastline_length = 4
    00

X is seeked from the end (SEEK\_END) by an offset equal to:

    k + (Y-X) + length($last_line)

Each item in the index is on its own line, with the following info:

- offset (with respect to X)
- name (stored encoded hexadecimal from byte representation - can be repeated)

Internal organization of a data section is with headers, empty line, body
exactly as a HTTP message.

Add a section
-------------

Adding a section involves:

* Reading current index
* Writing new section
* update and write index


ALL THE REST
============

Want to know more? [See the module's documentation](http://search.cpan.org/perldoc?Data::Embed) to figure out
all the bells and whistles of this module!

Want to install the latest release? [Go fetch it on CPAN](http://search.cpan.org/dist/Data-Embed/).

Want to contribute? [Fork it on GitHub](https://github.com/polettix/Data-Embed).

That's all folks!

