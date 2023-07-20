#!/bin/sh
set -x
dmd -O -m64 bax.d
rm *.o
