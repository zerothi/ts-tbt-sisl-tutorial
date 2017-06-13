#!/usr/bin/env python

from __future__ import print_function
import sisl

# This example creates a cross-bar graphene nano-ribbon
# and the electrodes to perform a 4-terminal calculation.
# For this N-electrode it is easier if it is 
# orthogonal (but you could do a non-orthogonal one)
graphene = sisl.geom.graphene(orthogonal=True)

# These are the tight-binding parameters
dR  = [0.1, 1.43]
hop = [0. , -2.7]

# Create the electrode for the graphene ribbons.
#  1. This electrode has the semi-infinite direction
#     along the second lattice vector.
elec_y = graphene.tile(3, axis=0)
elec_y.set_nsc([1, 3, 1])
elec_y.write('elec_y.xyz')
#  2. This electrode has the semi-infinite direction
#     along the first lattice vector.
elec_x = graphene.tile(5, axis=1)
elec_x.set_nsc([3, 1, 1])
elec_x.write('elec_x.xyz')

# Now create the Hamiltonian and store it
H_y = sisl.Hamiltonian(elec_y)
H_y.construct(dR, hop)
H_y.write('ELEC_Y.nc')    
H_x = sisl.Hamiltonian(elec_x)
H_x.construct(dR, hop)
H_x.write('ELEC_X.nc')

# Now create the full device by overlying 
# two graphene nano-ribbons
# Note that after having created the nano-ribbons
# we shift the atomic coordinates to origo.
dev_y = elec_y.tile(30, axis=1)
dev_y = dev_y.translate(-dev_y.center(which='xyz'))
dev_x = elec_x.tile(18, axis=0)
dev_x = dev_x.translate(-dev_x.center(which='xyz'))

device = dev_y.add(dev_x)
# Ensure that there are no super-cell interactions
device.set_nsc([1,1,1])
# Remove dublicates
dublicates = []
for ia in dev_y:
    idx = device.close(ia, 0.1)
    if len(idx) > 1:
        dublicates.append(idx[1])
device = device.remove(dublicates)

# Ensure the lattice vectors are big enough
# This is only for plotting, tbtrans does not care.
# Try and convince your-self that the lattice vectors are
# unimportant for tbtrans in this example.
# HINT: Periodicity.
device = device.append(sisl.SuperCell([100]), 0).append(sisl.SuperCell([100]), 1)
device = device.translate(device.center(which='cell'))

# Print the electrode positions of
# for tbtrans (these have been extracted and inserted into the
# fdf file for tbtrans).
print('elec-Y-1, semi-inf -A2: {}'.format(1))
print('elec-Y-2, semi-inf +A2: end {}'.format(len(dev_y)))
print('elec-X-1, semi-inf -A1: {}'.format(len(dev_y)+1))
print('elec-X-2, semi-inf +A1: end {}'.format(-1))

Hdev = sisl.Hamiltonian(device)
Hdev.construct([0.1, 1.43], [0, -2.7])
# We will create both a xyz file (for plotting in molden, etc.)
# and we will create the Hamilton file format for reading in tbtrans
Hdev.geom.write('device.xyz')
Hdev.write('DEVICE.nc')

