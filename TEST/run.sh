#!/bin/sh
set -x
cp ORIGINAL/* FIXED/
../bax "FIXED//*.bd"
