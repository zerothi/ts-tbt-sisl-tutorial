#/bin/bash

# This script uses the sdata command to selectively
# take certain atoms and only plot the DOS of those

# We run the sdata script

# We may also extract the bond-currents for the different
# branches
# This is extracting the bond-currents at E = 0.1 eV
for elec in x-1 y-1
do
    echo Creating vector transmissions for elec-$elec
    sdata siesta.TBT.nc \
    	  --vector vector_transmission 0.1 elec-$elec \
	  --out elec-${elec}_0.1.xsf
done
