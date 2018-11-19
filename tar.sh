#!/bin/bash

# This file will tar all examples and required files for
# the tutorial tar.gz file.

_files=
function add_file {
    while [ $# -gt 0 ];
    do
	_files="$_files $1"
	shift
    done
}

# Add manuals
add_file arch.make
add_file siesta.pdf tbtrans.pdf
add_file tselecs.sh

# Add IPython books
add_file tutorial.ipynb
add_file */run.ipynb

# Add RUN.fdf
add_file */RUN.fdf
add_file */RUN_ELEC.fdf
add_file */RUN_ELEC_*.fdf

# Add pseudo
add_file C.psf
add_file */C.psf
add_file */*/C.psf

# Add executables
add_file */run.sh

tar cfvz sisl-TBT-TS.tar.gz $_files
