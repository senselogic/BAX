#!/bin/sh
set -x
dmd -m64 bax.d
rm *.o
