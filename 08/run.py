#!/usr/bin/env python

import sisl

# Instead of manually defining the graphene system we use
# the build-in sisl capability of defining the graphene
# structure.
# Note that this graphene unit-cell is an orthogonal unit-cell
# (figure out how many atoms this consists off)
graphene = sisl.geom.graphene(1.44, orthogonal=True)

# There are two really important things in transiesta,
# besides the general DFT considerations such as k-mesh convergence
# mesh-cutoff etc.:
#
#  1. The electrode size (the extend of the electrode
#     in the semi-infinite direction)
#  2. The electrode screening region (the region
#     between the electrode and the device)
#
# For the first point you need an electrode with
# length such that the electrode only couples to one
# nearest neighbour unit-cell. This is extremely
# important for calculating the correct self-energy.
# In this case we create an electrode of 2 arm-chair direction
# components.
# The second point will be important in the following tutorials.
elec = graphene.tile(2, axis=0)
elec.write('STRUCT_ELEC.fdf')
elec.write('STRUCT_ELEC.xyz')

# This will be the "smaller" electrode to test the single
# cell interaction range.
graphene.write('STRUCT_ELEC_small.fdf')
graphene.write('STRUCT_ELEC_small.xyz')


# Now we create the device region.
# The device region *MUST* be so large that the electrodes
# does not connect directly. You may recognize that this
# requirement is the same as point 1 for the electrodes.
device = elec.tile(3, axis=0)
device.write('STRUCT_DEVICE.fdf')
device.write('STRUCT_DEVICE.xyz')
