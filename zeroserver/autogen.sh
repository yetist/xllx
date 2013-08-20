#!/bin/sh
aclocal
autoconf
autoheader
libtoolize -c -f
automake -a -c
