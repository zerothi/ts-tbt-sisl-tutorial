#!/usr/bin/env python

import sisl

# This example is created by two crossed 1D chains of
# carbon.
chain = sisl.Geometry([[0,0,0]], atom=sisl.Atom[6], sc=[1.4])

# Add some vacuum along the Z-direction
chain = chain.add_vacuum(15-1.4, axis=2)

# Create the electrodes
elec_x = chain.tile(4, axis=0)
elec_y = chain.tile(4, axis=1)

# Create the long chains
chain_x = elec_x.tile(4, axis=0)
chain_y = elec_y.tile(4, axis=1)

# Move both chains to the center
# This makes it easier to align the chains
chain_x = chain_x.translate(-chain_x.center(what='cell'))
chain_y = chain_y.translate(-chain_y.center(what='cell'))

# Create the full device
# This is required for correcting the supercell 
sc = chain_x.sc.copy()
sc.cell[2,2] = 2.1
sc.cell[1,1] = chain_y.cell[1,1]
device = chain_x.copy()
device.set_supercell(sc)
device = device.append(chain_y, 2).add_vacuum(15-2.1, 2)
device = device.translate(device.center(what='cell')).translate([.7]*3)

# Create the fdf files for all the geometries
elec_x = elec_x.add_vacuum(15-1.4, 1)
elec_x.write('ELEC_X.fdf')
elec_y = elec_y.add_vacuum(15-1.4, 0)
elec_y.write('ELEC_Y.fdf')
device.write('DEVICE.fdf')
device.write('DEVICE.xyz')
