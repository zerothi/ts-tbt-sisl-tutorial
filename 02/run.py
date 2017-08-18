#!/usr/bin/env python

import sisl

# Instead of manually defining the graphene system we use
# the build-in sisl capability of defining the graphene
# structure.
# Note that this graphene unit-cell is an orthogonal unit-cell
# (figure out how many atoms this consists off)
graphene = sisl.geom.graphene(orthogonal=True)

# Now as we have the graphene unit-cell, we can create the 
# Hamiltonian for the system.
H = sisl.Hamiltonian(graphene)

# Instead of using the for-loop shown in 01, we
# may use a simpler function that basically works for 1-orbital per
# atom models. For more orbitals per atom one has to create a function
# accordingly (see create_construct)
H.construct(([0.1, 1.43], [0., -2.7]))
    
# At this point we have created all Hamiltonian elements for all orbitals
# in the graphene geometry.
# Please try and figure out how many non-zero elements there should
# be in the Hamiltonian object.
# HINT: count the number of on-site and nearest-neighbour terms

# Now we have the Hamiltonian, now we need to save it to be able 
# to conduct a tbtrans calculation:
# As this is the minimal unit-cell we call this the electrode
# and we will in the following create a larger "DEVICE" region
# Hamiltonian.
H.write('ELEC.nc')

# Now we need to create the device region Hamiltonian.
# The tbtrans method relies on including the electrodes 
# in the device region. Hence the smallest device region 
# must be 3 times the electrode size.
# Please try and convince your-self that this is the case.
# HINT: consider the interaction range of the atoms

# We tile the geometry along the 2nd lattice vector
# (Python is 0-based indexing)
device = graphene.tile(3, axis=1)
Hdev = sisl.Hamiltonian(device)

# Again we have to construct the Hamiltonian using the construct
# routine call.
Hdev.construct(([0.1, 1.43], [0, -2.7]))

# We will create both a xyz file (for plotting in molden, etc.)
# and we will create the Hamiltonian file format for reading in tbtrans
Hdev.geom.write('device.xyz')
Hdev.write('DEVICE.nc')


# The above code calls `construct` twice. However, for extremely
# large systems (>500,000) the `construct` function will be rather
# slow.
# Instead we can use the periodicity of the initial graphene
# electrode Hamiltonian (i.e. the smallest orthogonal
# unit-cell Hamiltonian).
#
# Try and run the following two lines of code to get help:
#
#   >>> help(sisl.Geometry.tile)
#   >>> help(sisl.Hamiltonian.tile)
#
# I.e. one can also tile (or repeat) a Hamiltonian object.
# And this is *much* faster!
#
# You should make a copy of this code and adapt it to *only* have
# one `construct` call, the resulting code should also be shorter (by 2 lines).


