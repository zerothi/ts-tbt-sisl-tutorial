#!/usr/bin/env python

import sisl

# This example is _exactly_ equivalent to 08.
# The purpose is to try and perform a bias calculation 
# on pristine graphene.
graphene = sisl.geom.graphene(1.44, orthogonal=True)

elec = graphene.tile(2, axis=0)
elec.write('STRUCT_ELEC.fdf')
elec.write('STRUCT_ELEC.xyz')

device = elec.tile(3, axis=0)
device.write('STRUCT_DEVICE.fdf')
device.write('STRUCT_DEVICE.xyz')
