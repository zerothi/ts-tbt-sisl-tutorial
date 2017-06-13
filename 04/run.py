#!/usr/bin/env python

from __future__ import print_function
import sisl

# Instead of manually defining the graphene system we use
# the build-in sisl capability of defining the graphene
# structure.
# (figure out how many atoms this consists off)
graphene = sisl.geom.graphene()

# Now as we have the graphene unit-cell, we can create the 
# Hamiltonian for the electrode by first
# repeating it 25 times along the first lattice vector.
elec = graphene.repeat(25, axis=0)
H = sisl.Hamiltonian(elec)

# Instead of using the for-loop provided in 01, we
# may use a simpler function that *ONLY* works
# for 1-orbital per atom models.
H.construct([0.1, 1.43], [0., -2.7])
    
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
# must be a multiple of 3 of the electrode size.
# Please try and convince your-self that this is the case.
# HINT: consider the interaction range of the atoms

# We tile the geometry along the 2nd lattice vector
# (Python is 0-based indexing)
device = elec.tile(15, axis=1)
# Remove a hole in the flake
device = device.remove(device.close(device.center(which='cell'), dR=10.))

# We will also (for physical reasons) remove all dangling bonds:
dangling = []
for ia in device.close(device.center(which='cell'), dR=14.):
    if len(device.close(ia, dR=1.43)) < 3:
        dangling.append(ia)
device = device.remove(dangling)
edge = []
for ia in device.close(device.center(which='cell'), dR=14.):
    if len(device.close(ia, dR=1.43)) < 4:
        edge.append(ia)
# Now we have all the edge atoms.
# Print the FORTRAN indices for sdata
edge.sort()
pos = [j - i for i, j in enumerate(edge)]
from itertools import groupby
t = 0
for i, els in groupby(pos):
    l = len(list(els))
    el = edge[t] + 1
    if t > 0:
        print(',', end='')
    t += l
    if l == 1:
        print(el, end='')
    else:
        print('{}-{}'.format(el, el+l-1), end='')
print('')
print('51-100')

Hdev = sisl.Hamiltonian(device)
Hdev.construct([0.1, 1.43], [0, -2.7])
# We will create both a xyz file (for plotting in molden, etc.)
# and we will create the Hamilton file format for reading in tbtrans
Hdev.geom.write('device.xyz')
Hdev.write('DEVICE.nc')

