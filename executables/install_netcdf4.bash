#!/bin/bash

# Installation script for zlib, hdf5, netcdf-c and netcdf-fortran
# with complete CDF-4 support (in serial).
# This installation script has been written by:
#  Nick R. Papior, 2016-2018.
#
# The author takes no responsibility of damage done to your hardware or
# software. It is up to YOU that the script executes the correct commands.
#
# This script is released under the LGPL license.

# VERY BASIC installation script of required libraries
# for installing these packages:
#   zlib-1.2.11
#   hdf5-1.8.21
#   netcdf-c-4.6.1
#   netcdf-fortran-4.4.4
# If you want to change your compiler version you should define the
# global variables that are used for the configure scripts to grab the
# compiler, they should be CC and FC. Also if you want to compile with
# different flags you should export those variables; CFLAGS, FFLAGS.

# If you have downloaded other versions edit these version strings
z_v=1.2.11
h_v=1.8.21
nc_v=4.6.1
nf_v=4.4.4

# Install path, change accordingly
# You can change this variable to control the installation path
# If you want the installation path to be a "packages" folder in
# your home directory, change to this:
# ID=$HOME/packages
ID=$(pwd)/static-libs

echo "Installing libraries in folder: $ID"
mkdir -p $ID

# First we check that the user have downloaded the files
function file_exists {
    if [ ! -e $(pwd)/$1 ]; then
	echo "I could not find file $1..."
	echo "Please download the file and place it in this folder:"
	echo " $(pwd)"
	exit 1
    fi
}

# First we check that the user have downloaded the files
function dwn_file {
    [ -e $2 ] && return 0
    wget -O $2 $1
    if [ $? -ne 0 ]; then
	rm -f $2
    fi
}

# Check for function $?
function retval {
    local ret=$1
    local info="$2"
    shift 2
    if [ $ret -ne 0 ]; then
	echo "Error: $ret"
	echo "$info"
	exit 1
    fi
}

dwn_file http://zlib.net/zlib-${z_v}.tar.gz .zlib-${z_v}.tar.gz
dwn_file https://support.hdfgroup.org/ftp/HDF5/releases/hdf5-1.8/hdf5-${h_v}/src/hdf5-${h_v}.tar.bz2 .hdf5-${h_v}.tar.bz2
dwn_file https://github.com/Unidata/netcdf-c/archive/v${nc_v}.tar.gz .netcdf-c-${nc_v}.tar.gz
dwn_file https://github.com/Unidata/netcdf-fortran/archive/v${nf_v}.tar.gz .netcdf-fortran-${nf_v}.tar.gz
unset dwn_file

file_exists .zlib-${z_v}.tar.gz
file_exists .hdf5-${h_v}.tar.bz2
file_exists .netcdf-c-${nc_v}.tar.gz
file_exists .netcdf-fortran-${nf_v}.tar.gz
unset file_exists

#################
# Install z-lib #
#################
[ -e $ID/lib64/libz.a ] && zlib_lib=lib64 || zlib_lib=lib
if [ ! -e $ID/$zlib_lib/libz.a ]; then
    tar xfz .zlib-${z_v}.tar.gz
    cd zlib-${z_v}
    ./configure --prefix $ID
    retval $? "zlib config"
    make
    retval $? "zlib make"
    make test 2>&1 | tee zlib.test
    retval $? "zlib make test"
    make install
    retval $? "zlib make install"
    mv zlib.test $ID/
    cd ../
    rm -rf zlib-${z_v}
    echo "Completed installing zlib"
    [ -e $ID/lib64/libz.a ] && zlib_lib=lib64 || zlib_lib=lib
else
    echo "zlib directory already found."
fi

################
# Install hdf5 #
################
[ -e $ID/lib64/libhdf5.a ] && hdf5_lib=lib64 || hdf5_lib=lib
if [ ! -e $ID/$hdf5_lib/libhdf5.a ]; then
    tar xfj .hdf5-${h_v}.tar.bz2
    cd hdf5-${h_v}
    mkdir build ; cd build
    ../configure --prefix=$ID --enable-static \
		 --enable-fortran --with-zlib=$ID
		 LDFLAGS="-L$ID/$zlib_lib -Wl,-rpath=$ID/$zlib_lib"
    retval $? "hdf5 configure"
    make
    retval $? "hdf5 make"
    make check-s 2>&1 | tee hdf5.test
    retval $? "hdf5 make check-s"
    make install
    retval $? "hdf5 make install"
    mv hdf5.test $ID/
    cd ../../
    rm -rf hdf5-${h_v}
    echo "Completed installing hdf5"
    [ -e $ID/lib64/libhdf5.a ] && hdf5_lib=lib64 || hdf5_lib=lib
else
    echo "hdf5 directory already found."
fi

####################
# Install NetCDF-C #
####################
[ -e $ID/lib64/libnetcdf.a ] && cdf_lib=lib64 || cdf_lib=lib
if [ ! -e $ID/$cdf_lib/libnetcdf.a ]; then
    tar xfz .netcdf-c-${nc_v}.tar.gz
    cd netcdf-c-${nc_v}
    mkdir build ; cd build
    ../configure --prefix=$ID --enable-static \
		 --enable-netcdf-4 --disable-dap \
		 CPPFLAGS="-I$ID/include" \
		 LDFLAGS="-L$ID/$hdf5_lib -Wl,-rpath=$ID/$hdf5_lib -L$ID/$zlib_lib -Wl,-rpath=$ID/$zlib_lib"
    retval $? "netcdf configure"
    make
    retval $? "netcdf make"
    make install
    retval $? "netcdf make install"
    cd ../../
    rm -rf netcdf-c-${nc_v}
    echo "Completed installing C NetCDF library"
    [ -e $ID/lib64/libnetcdf.a ] && cdf_lib=lib64 || cdf_lib=lib
else
    echo "netcdf directory already found."
fi

##########################
# Install NetCDF-Fortran #
##########################
if [ ! -e $ID/$cdf_lib/libnetcdff.a ]; then
    tar xfz .netcdf-fortran-${nf_v}.tar.gz
    cd netcdf-fortran-${nf_v}
    mkdir build ; cd build
    ../configure CPPFLAGS="-DgFortran -I$ID/include" \
		 LIBS="-L$ID/$zlib_lib -Wl,-rpath=$ID/$zlib_lib \
	-L$ID/$hdf5_lib -Wl,-rpath=$ID/$hdf5_lib \
	-L$ID/$cdf_lib -Wl,-rpath=$ID/$cdf_lib \
	-lnetcdf -lhdf5hl_fortran -lhdf5_fortran -lhdf5_hl -lhdf5 -lz" \
		 --prefix=$ID --enable-static
    retval $? "netcdf-fortran configure"
    make
    retval $? "netcdf-fortran make"
    make check 2>&1 | tee check.fortran.serial
    retval $? "netcdf-fortran make check"
    make install
    retval $? "netcdf-fortran make install"
    mv check.fortran.serial $ID/
    cd ../../
    rm -rf netcdf-fortran-${nf_v}
    echo "Completed installing Fortran NetCDF library"
else
    echo "netcdf-fortran library already found."
fi

##########################
# Completed installation #
##########################

echo ""
echo "##########################"
echo "# Completed installation #"
echo "#   of NetCDF package    #"
echo "#  and its dependencies  #"
echo "##########################"
echo ""
echo ""

echo "Please add the following to the BOTTOM of your arch.make file"
echo ""
echo "INCFLAGS += -I$ID/include"
echo "LDFLAGS += -L$ID/$zlib_lib -Wl,-rpath=$ID/$zlib_lib"
if [ $hdf5_lib != $zlib_lib ]; then
    echo "LDFLAGS += -L$ID/$hdf5_lib -Wl,-rpath=$ID/$hdf5_lib"
fi
if [ $cdf_lib != $zlib_lib ]; then
    echo "LDFLAGS += -L$ID/$cdf_lib -Wl,-rpath=$ID/$cdf_lib"
fi
echo "LIBS += -lnetcdff -lnetcdf -lhdf5_hl -lhdf5 -lz"
echo "COMP_LIBS += libncdf.a libfdict.a"
echo "FPPFLAGS += -DCDF -DNCDF -DNCDF_4"
echo ""
