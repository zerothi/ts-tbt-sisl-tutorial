### Notes
# Compilation of static OpenBLAS with dynamic architecture may be
# done like this:
#   make clean
#   make DYNAMIC_ARCH=1 USE_THREAD=1 NUM_THREADS=4 USE_OPENMP=1 BINARY=64 SANITY_CHECK=1 MAX_STACK_ALLOC=2048 NO_LAPACK=0 CC=gcc FC=gfortran libs
# To install the NetCDF suite, simply do:
#   ./install_netcdf4.bash

# Define whether the program should be compiled with SSE/AVX/AVX2
USE_SSE ?= 0
USE_AVX ?= 0
USE_AVX2 ?= 0

.SUFFIXES:
.SUFFIXES: .f .F .c .o .a .f90 .F90

SIESTA_ARCH=x86_64-gfortran-serial-static
FPP = gfortran
FPP_OUTPUT=
FC = gfortran
FC_SERIAL = gfortran
AR = gcc-ar
RANLIB = gcc-ranlib
SYS  = nag
SP_KIND = 4
DP_KIND = 8
KINDS = $(SP_KIND) $(DP_KIND)

# Generic paths
#INC_PATH = -I/usr/local/include/ -I/usr/include/
#LIB_PATH = -L/usr/local/lib -L/usr/lib

# Add local paths for NetCDF4 installation and OpenBLAS
INSTALL_NCDF4_PATH = /home/nicpa/siesta/ts-tbt-sisl-tutorial/executables/static-libs
INC_PATH = -I$(INSTALL_NCDF4_PATH)/include
LIB_PATH = -L$(INSTALL_NCDF4_PATH)/lib -L$(INSTALL_NCDF4_PATH)/lib64

FFLAGS = -m64 -fPIC -O2 -ftree-vectorize -fexpensive-optimizations -fno-second-underscore $(INC_PATH)

ifeq ($(USE_AVX2),1)
  FFLAGS += -mavx2
  USE_AVX := 1
endif
ifeq ($(USE_AVX),1)
  FFLAGS += -mavx
  USE_SSE := 1
endif
ifeq ($(USE_SSE),1)
  FFLAGS += -msse2
endif

INCFLAGS += $(INC_PATH)

FPPFLAGS = -DFC_HAVE_FLUSH -DFC_HAVE_ABORT -DCDF -DNCDF -DNCDF_4
COMP_LIBS = libncdf.a libfdict.a
COMP_LIBS += libsiestaLAPACK.a libsiestaBLAS.a

LDFLAGS = $(LIB_PATH)

# These two flags should work:
NETCDF_LIBS = -lnetcdff -lnetcdf

# The hdf5 libraries may have different names
#NETCDF_LIBS += -lhdf5 -lhdf5_serial 
# Or
#NETCDF_LIBS += -lhdf5
NETCDF_LIBS += -lhdf5_hl -lhdf5

# Finally add zlib (and dl which is needed for HDF5, but ain't used)
NETCDF_LIBS += -lz -ldl

LIBS += $(NETCDF_LIBS)

# Ensure the executable is static
FFLAGS += -static
LDFLAGS += -static

#Dependency rules are created by autoconf according to whether
#discrete preprocessing is necessary or not.
.F.o:
	$(FC) -c $(FFLAGS) $(INCFLAGS) $(FPPFLAGS) $(FPPFLAGS_fixed_F)  $< 
.F90.o:
	$(FC) -c $(FFLAGS) $(INCFLAGS) $(FPPFLAGS) $(FPPFLAGS_free_F90) $< 
.f.o:
	$(FC) -c $(FFLAGS) $(INCFLAGS) $(FCFLAGS_fixed_f)  $<
.f90.o:
	$(FC) -c $(FFLAGS) $(INCFLAGS) $(FCFLAGS_free_f90)  $<
