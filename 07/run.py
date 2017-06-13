from __future__ import print_function, division

import math, time
import numpy as np

import sisl as si

# In order to use the construct feature we
# must define an orbital range of the
# atoms.
# Note that we use a Hydrogen atom, but
# in principle is the atomic number not
# used for anything.
H = si.Atom(1, R=1.1)

# These are the tight-binding quantities
# Create tight-binding H
R = [0.1, 1.1]
on, nn = 4, -1

# Read and create the electrode
print('Creating electrode electronic structure...')
elec = si.Geometry.read('electrode-square.xyz')
elec.atom[:] = H
# The electrode is a nano-ribbon
elec.sc.set_nsc([3,1,1])
H_el = si.Hamiltonian(elec)
H_el.construct((R, [on, nn]))
H_el.write('ELEC.nc')

# First we read the device from the xyz file
print('Reading and creating device electronic structure...')
device = si.Geometry.read('device.xyz')
device.atom[:] = H
# The device has no supercell connections
device.sc.set_nsc([1,1,1])
H_dev = si.Hamiltonian(device)
H_dev.construct((R, [on, nn]))
H_dev.write('DEVICE.nc')

# Now we may easily create the B-field
# corrections for the different hopping integrals.
# First we will create a sparse matrix
# with the phases.
# This is a "trick" to greatly speed up the creation of the
# dH files.
# We create one dH with all phases, and we will
# subsequently calculate the complex phases
# from the phases in one go.
print('Initialization of the phases for B-field...')
phases = si.Hamiltonian(device)
for ias, idxs in device.iter_block(17):
    for ia in ias:

        # Retrive BOTH the index of the overlaps *and* the
        # coordinates of the atoms that are connecting
        idx, xyz = device.close(ia, R, idx=idxs, ret_xyz=True)
        
        # In the magnetic field Peierls substitution
        # we only want to change the nearest-neighbour elements
        idx, xyz = idx[1], xyz[1]

        # This is a B-field in the z-direction
        # So the phases are due to x-y coordinates
        phase = (device[ia,0] - xyz[:,0]) * \
                (device[ia,1] + xyz[:,1])

        phases[ia, idx] = phase
phases.finalize()

# Now `phases` contain all hopping integral delta-r from which
# we may calculate the Peierls phase:
#   H = H * exp( i/2 * Phi * dx * dx )
# Loop over all Phi and store the magnetic correction
# in the M_*.dH.nc files.s
# Subsequently one may call:
#   tbtrans -fdf TBT.dH:M_1.0.dH.nc
# which will add the dH using the data in M_1.0.dH.nc
reciprocal_phis = np.linspace(5, 50, 16)
for i, rec_phi in enumerate(reciprocal_phis):
    print("{:4d} - Creating dH for 1/phi = {}".format(i+1, rec_phi))

    # Convert reciprocal-phi to: i * phi /2
    phi = -0.5j / rec_phi

    # Calculate the phases
    # The dH is an additive term for the
    # Hamiltonian, hence we should subtract the
    # hopping integral and set the new one
    # as the magnetic field is a phase-factor.
    dH = nn * math.e ** (phi * phases) - nn

    # Now we have dH at magnetic field (phi)
    sile = si.get_sile('M_{:.0f}.dH.nc'.format(rec_phi), 'w')

    dH.write(sile)
