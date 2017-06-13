#!/usr/bin/env python

# This tutorial setup the necessary files for running
# a simple graphene system example.

# We will HEAVILY encourage to use Python3 compliant code
# This line ensures the code will run using either Python2 or Python3
from __future__ import print_function

# First we require the use of the sisl Python module.
import sisl

# Instead of manually defining the graphene system we use
# the build-in sisl capability of defining the graphene
# structure.
graphene = sisl.geom.graphene()

# Print out some basic information about the geometry we have
# just created.
print("Graphene geometry information:")
print(graphene)
print()
# It should print that the geometry consists of
#   2 atoms (na)
#   2 orbitals (no), one per atom
#   1 specie (C), both atoms are the same atomic specie
#   orbital range of 1.4342 AA (dR)
#   3x3 supercell (nsc), this is determined from dR

# Now as we have the graphene unit-cell, we can create the 
# Hamiltonian for the system.
H = sisl.Hamiltonian(graphene)
print("Graphene initial Hamiltonian information:")
print(H)
print()

# Currently this Hamiltonian is an empty entity, i.e.
# no hopping elements has been assigned (all H[i,j] == 0).
# For graphene, one may use these tight-binding parameters:
#  on-site: 0. eV
#  nearest-neighbour: -2.7 eV
# In the following loop we setup the Hamiltonian with the above
# tight-binding parameters:
for ia, io in H:
	# This loop construct loops over all atoms and the orbitals
    # corresponding to the atom.
	# In this case the geometry has one orbital per atom, hence
    #   ia == io
    # in all cases.
    
    # In order to figure out which atoms atom `ia` is connected
    # to, we must find those atoms
    # To do this we access the geometry attached to the 
    # Hamiltonian (H.geom)
    # and use a function called `close` which returns ALL 
    # atoms within certain ranges of a given point or atom
    idx = H.geom.close(ia, dR = (0.1, 1.43))
    # the argument dR has two entries:
    #   0.1 and 1.43
    # Each value represents a radii of a sphere.
    # The `close` function will then return
    # a list of equal length of the dR argument (i.e. a list with
    # two values).
    # Then idx[0] is the first element and this contains a list
    # of all atoms within a sphere of 0.1 AA of atom `ia`.
    # This should obviously only contain the atom it-self.
    # The second element, idx[1] contains all atoms within a sphere
    # with radius of 1.43 AA, but not including those within 0.1 AA.
    # In this case this is then all atoms that are the nearest neighbour
    # atoms
   
    # Now we know the on-site atoms (idx[0]) and the nearest neighbour
    # atoms (idx[1]), all we need to do is set the Hamiltonian
    # elements:

    # on-site (0. eV)
    H[io, idx[0]] = 0.
   
    # nearest-neighbour (-2.7 eV)
    H[io, idx[1]] = -2.7
    
# At this point we have created all Hamiltonian elements for all orbitals
# in the graphene geometry.
# Let's try and print the information of the Hamiltonian object:
print("Hamiltonian after setting up the parameters:")
print(H)
print()
# It now prints that there are 8 non-zero elements.
# Please convince yourself that this is the correct number of 
# Hamiltonian elements (regard the on-site value of 0. eV as a non-zero
# value). HINT: count the number of on-site and nearest-neighbour terms)

# At this point we have all the ingredients for manipulating the electronic
# structure of graphene in a tight-binding model with nearest neighbour 
# interactions.

# We may, for instance, calculate the eigen-spectrum at the Gamma-point:
print("Eigenvalues at Gamma:")
print(H.eigh())
print("Eigenvalues at K:")
print(H.eigh(k=[1./3,2./3,0]))
print()

# Additionally we may calculate the band-structure of graphene
# We want to plot the band-structure of graphene

from graphene_band_structure import bandstructure

# Now lets plot the band-structure (requires matplotlib)
bandstructure(301, H)

