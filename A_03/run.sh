#!/bin/bash

# Run tbtrans on the non-magnetic system
    if [ -d M_0 ] ; then
        echo "Skipping no magnetic field. Please, remove/rename folder M_0/."
    else
        echo "Running no magnetic field"
        tbtrans -D M_0 RUN.fdf > TBT.out
    fi

# Loop over the M_*.dH.nc files created with 'run.py'
for f in M_*.dH.nc
do
    B=${f//.dH.nc/}

    # Clean Magnetic directory
    if [ -d $B/ ] ; then
        echo "Skipping $f. Please, remove/rename folder $B/."
    else
        echo "Running for dH = $f"
        tbtrans -D $B -fdf TBT.dH:$f RUN.fdf > TBT_$B.out
    fi
#    rm -rf $B/
    
    # Run tbtrans in a separate directory for each B
#    tbtrans -D $B -fdf TBT.dH:$f RUN.fdf > TBT_$B.out

done
