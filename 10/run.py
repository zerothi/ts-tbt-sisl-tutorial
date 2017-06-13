#!/usr/bin/env python

import sisl

# In this example you should create a 1D chain 
# of Carbon and perform a transiesta calculation.
C = sisl.Atom(6)

# The chain should consist of Carbon atoms with
# an inter-atomic distance of 1.5 Å.

# 1. Create the electrode
#    Supply the coordinates,
#    Note that you _have_ to decide the semi-infinite
#    direction by ensuring the electrode to 
#    be periodic in the semi-infinite direction.
elec = sisl.Geometry(<fill-in coordinates>,
                     atom=C,
                     sc=<unit-cell size>)
elec.write('ELEC.fdf')

# 2. Create the device
#    The basic unit-cell for a fully periodic device
#    system is 3-times the electrode size.
#    HINT: If you are not fully sure why this is, please
#          re-iterate on example 08.
device = elec.tile(3, axis=<semi-infinite direction>)
device.write('DEVICE.fdf')




