#!/usr/bin/env python

import sisl

# This example will create an STM-like setup with
# graphene as the basal plane and a carbon chain
# above to act as an STM-tip.
# (please note that in a more physical setup one
# would use other species in the tip, gold for example)

# First we create the graphene plane
graphene = sisl.geom.graphene(1.44)

# Create the graphene electrode
elec = graphene.tile(2, axis=0)
elec.write('ELEC_GRAPHENE.fdf')
elec.write('ELEC_GRAPHENE.xyz')

# Create the STM tip electrode
# First we create the basic 1D chain
C1d = sisl.Geometry([[0,0,0]], sisl.Atom(6), [10, 10, 1.4])
# Create the electrode
elec_chain = C1d.tile(4, axis=2)
elec_chain.write('ELEC_CHAIN.fdf')
elec_chain.write('ELEC_CHAIN.xyz')
# Create the full STM-tip
chain = elec_chain.tile(4, axis=2)

# Create the device
device = elec.repeat(5, axis=1).tile(4, axis=0)

# Attach the chain on-top of an atom
# First find an atom in the middle of the device
idx = device.close(device.center(which='cell')*[1,1,0], dR=1.45)[1]
# Attach the chain at a distance of 2.25 along the third lattice vector
device = device.attach(idx, chain, 0, dist=2.25, axis=2)
# Add vacuum along chain, we really no not care how much vacuum, but it
# is costly on memory.
device = device.append(sisl.SuperCell([15]), axis=2)

device.write('DEVICE.fdf')
device.write('DEVICE.xyz')
