.SUFFIXES:
.SUFFIXES: .f .F .c .o .a .f90 .F90

SIESTA_ARCH=x86_64-macos-gfortran-serial
FPP = gfortran
FPP_OUTPUT=
FC = gfortran
FC_SERIAL = gfortran
AR = ar
RANLIB = ranlib
SYS  = nag
SP_KIND = 4
DP_KIND = 8
KINDS = $(SP_KIND) $(DP_KIND)

# Generic paths
INC_PATH = -I/usr/local/include/ -I/usr/include/
LIB_PATH = -L/usr/local/lib -L/usr/lib

FFLAGS = -m64 -fPIC -O2 -ftree-vectorize $(INC_PATH)

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
NETCDF_LIBS += -lhdf5

# Finally add zlib (and dl which is needed for HDF5, but ain't used)
NETCDF_LIBS += -lz -ldl

LIBS += $(NETCDF_LIBS)

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
