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
add_file siesta.pdf tbtrans.pdf
add_file tselecs.sh

# Add IPython books
add_file tutorial.ipynb
add_file [^w]*/*.ipynb

# Add RUN.fdf
add_file [^w]*/RUN.fdf
add_file [^w]*/RUN_ELEC.fdf
add_file [^w]*/RUN_ELEC_*.fdf

# Add pseudo
add_file *.psf
add_file [^w]*/*.psf
add_file [^w]*/*/*.psf
add_file *.psml
add_file [^w]*/*.psml
add_file [^w]*/*/*.psml

# Add executables
add_file [^w]*/run.sh
add_file A_05/C60.xyz

add_file external/hubbard-tutorials.tar.gz
add_file external/Balogh_TB_extended.ipynb
add_file external/MachineLearning_Hamiltonians.ipynb

tar cfvz sisl-TBT-TS.tar.gz $_files
