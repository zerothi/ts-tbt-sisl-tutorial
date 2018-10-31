#!/bin/bash

# This script uses the sdata command to selectively
# take certain atoms and only plot the DOS of those

# Group DOS of graphene and chain
for elec in graphene-1 graphene-2 chain
do
    echo Creating atomic DOS for electrode: $elec
    sdata siesta.TBT.nc \
	  --atom 21:60 --dos --ados $elec \
	  --atom 81:90 --dos --ados $elec \
	  --atom : --dos --ados $elec \
	  --out atomic-DOS-$elec.dat
done

