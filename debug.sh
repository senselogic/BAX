#!/bin/sh
set -x
dmd -debug -g -gf -gs -m64 bax.d
rm *.o
