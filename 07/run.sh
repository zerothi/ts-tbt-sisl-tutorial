#!/bin/bash

# Run tbtrans on the non-magnetic system
tbtrans RUN.fdf > TBT.out

# Loop over the M_*.dH.nc files created with 'run.py'
for f in M_*.dH.nc
do
    echo "Running for dH =  $f"
    B=${f//.dH.nc/}

    # Clean Magnetic directory
    rm -rf $B/
    
    # Run tbtrans in a separate directory for each B
    tbtrans -D $B -fdf TBT.dH:$f RUN.fdf > TBT_$B.out

done
