#/bin/bash

# This script uses the sdata command to selectively
# take certain atoms and only plot the DOS of those

# We run the sdata script

# We may also extract the bond-currents in the graphene
# plane and plot them using XSF
# This is extracting the bond-currents at E = 0.1 eV
for elec in X-1 X-2 Y-1 Y-2
do
    echo Creating vector-currents for elec-$elec
    sdata siesta.TBT.nc \
    	  --vector vector_current elec-$elec 0.1 \
	  --out elec-${elec}_0.1.xsf
done
