#/bin/bash

# This script uses the sdata command to selectively
# take certain atoms and only plot the DOS of those

# We run the sdata script

# First we take all atoms in the circle which only connects to
# two carbon atoms (i.e. the edge atoms in the hole)
a="190,214-215,237-238,259-260,299-300,338,356,375,394,431-432,452,473-474,496-498"
sdata siesta.TBT.nc --atom $a --dos \
      --bulk-dos Left --ados Left \
      --bulk-dos Right --ados Right \
      --out edge_atoms.dat

# Now only take the firs line of graphene atoms (pristine)
a="51-100"
sdata siesta.TBT.nc --atom $a --dos \
      --bulk-dos Left --ados Left \
      --bulk-dos Right --ados Right \
      --out pristine_atoms.dat

# We may also extract the bond-currents in the graphene
# plane and plot them using XSF
# This is extracting the bond-currents at E = 0.1 eV
sdata siesta.TBT.nc \
      --vector vector_current Left 0.1 \
      --out left_0.1.xsf
sdata siesta.TBT.nc \
      --vector vector_current Right 0.1 \
      --out right_0.1.xsf

