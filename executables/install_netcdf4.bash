#!/bin/bash

# Installation script for zlib, hdf5, netcdf-c and netcdf-fortran
# with complete CDF-4 support (in serial).
# This installation script has been written by:
#  Nick R. Papior, 2016-2020.
#
# The author takes no responsibility of damage done to your hardware or
# software. It is up to YOU that the script executes the correct commands.
#
# This script is released under the LGPL license.

# VERY BASIC installation script of required libraries
# for installing these packages:
#   zlib-1.2.11
#   hdf5-1.12.0
#   netcdf-c-4.7.2
#   netcdf-fortran-4.5.2
# If you want to change your compiler version you should define the
# global variables that are used for the configure scripts to grab the
# compiler, they should be CC and FC. Also if you want to compile with
# different flags you should export those variables; CFLAGS, FFLAGS.

# If you have downloaded other versions edit these version strings
z_v=1.2.11
h_v=1.12.0
nc_v=4.7.2
nf_v=4.5.2

# Install path, change accordingly
# You can change this variable to control the installation path
# If you want the installation path to be a "packages" folder in
# your home directory, change to this:
# ID=$HOME/packages
if [ -z $PREFIX ]; then
    ID=$(pwd)/build
else
    ID=$PREFIX
fi
# Decide whether everything is installed in 1 directory
_single_dir=1

while [ $# -gt 0 ]; do
    opt=$1 ; shift
    case $opt in
	--prefix|-p)
	    ID=$1 ; shift
	    ;;
	--libz-version|-libz-v)
	    z_v=$1 ; shift
	    ;;
	--hdf5-version|-hdf5-v)
	    h_v=$1 ; shift
	    ;;
	--netcdf-c-version|-nc-v)
	    nc_v=$1 ; shift
	    ;;
	--netcdf-f-version|-nf-v)
	    nf_v=$1 ; shift
	    ;;
	--single-directory)
	    _single_dir=1
	    ;;
	--separate-directory)
	    _single_dir=0
	    ;;
	--help|-h)
	    echo " $0 --help shows this message"
	    echo ""
	    echo "These options are available:"
	    echo ""
	    echo "  --prefix|-p : specify the installation directory of the libraries"
	    echo "  --libz-version|-libz-v : specify the libz version (default: $z_v)"
	    echo "  --hdf5-version|-hdf5-v : specify the HDF5 version (default: $h_v)"
	    echo "  --netcdf-c-version|-nc-v : specify the NetCDF-C version (default: $nc_v)"
	    echo "  --netcdf-f-version|-nf-v : specify the NetCDF-fortran version (default: $nf_v)"
	    echo "  --single-directory : all libraries are installed in --prefix/{bin,lib,include} (default: YES)"
	    echo "  --separe-directory : all libraries are installed in --prefix/<package>/<version>/{bin,lib,include} (default: NO)"
	    echo ""
	    exit 0
	    ;;
    esac
done


echo "Installing libraries in folder: $ID"
echo ""
echo "Using these software versions:"
echo "  libz    : $z_v"
echo "  hdf5    : $h_v"
echo "  netcdf-c: $nc_v"
echo "  netcdf-f: $nf_v"
echo ""
echo "If you want other versions, please try $0 --help and check the options"
echo "  Will wait 2 sec before proceeding"
echo ""
sleep 2

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

# Download a file, if able and the file does not exist
which wget > /dev/null
if [ $? -eq 0 ]; then
    # success we can download using wget
    function _dwn_file {
	wget -O $1 $2
    }
else
    function _dwn_file {
	curl -o $1 $2
    }
fi

# Use download function
#  $1 is name of file
#  $2 is URL
function download_file {
    if [ ! -e $(pwd)/$1 ] ; then
	# Try and download
	_dwn_file $1 $2
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

# Download files if they can
download_file zlib-${z_v}.tar.gz https://www.zlib.net/zlib-${z_v}.tar.gz
download_file hdf5-${h_v}.tar.bz2 https://hdf-wordpress-1.s3.amazonaws.com/wp-content/uploads/manual/HDF5/HDF5_${h_v//./_}/source/hdf5-${h_v}.tar.bz2
download_file netcdf-c-${nc_v}.tar.gz https://github.com/Unidata/netcdf-c/archive/v${nc_v}.tar.gz
download_file netcdf-fortran-${nf_v}.tar.gz https://github.com/Unidata/netcdf-fortran/archive/v${nf_v}.tar.gz

file_exists zlib-${z_v}.tar.gz
file_exists hdf5-${h_v}.tar.bz2
file_exists netcdf-c-${nc_v}.tar.gz
file_exists netcdf-fortran-${nf_v}.tar.gz
unset file_exists

#################
# Install z-lib #
#################
if [ $_single_dir -eq 0 ]; then
    zlib_dir=$ID/zlib/$z_v
else
    zlib_dir=$ID
fi
[ -d $zlib_dir/lib64 ] && zlib_lib=lib64 || zlib_lib=lib
if [ ! -e $zlib_dir/$zlib_lib/libz.a ]; then
    tar xfz zlib-${z_v}.tar.gz
    cd zlib-${z_v}
    ./configure --prefix $zlib_dir/
    retval $? "zlib config"
    make -j 2
    retval $? "zlib make"
    make test 2>&1 | tee zlib.test
    retval $? "zlib make test"
    make install
    retval $? "zlib make install"
    mv zlib.test $zlib_dir/
    cd ../
    rm -rf zlib-${z_v}
    echo "Completed installing zlib"
    [ -d $zlib_dir/lib64 ] && zlib_lib=lib64 || zlib_lib=lib
else
    echo "zlib directory already found."
fi

################
# Install hdf5 #
################
if [ $_single_dir -eq 0 ]; then
    hdf_dir=$ID/hdf5/$h_v
else
    hdf_dir=$ID
fi
[ -d $hdf_dir/lib64 ] && hdf_lib=lib64 || hdf_lib=lib
if [ ! -e $hdf_dir/$hdf_lib/libhdf5.a ]; then
    rm -rf hdf5-$h_v
    tar xfj hdf5-$h_v.tar.bz2
    cd hdf5-$h_v
    mkdir build ; cd build
    ../configure --prefix=$hdf_dir \
	--enable-shared --enable-static \
	--enable-fortran --with-zlib=$zlib_dir \
	LDFLAGS="-L$zlib_dir/$zlib_lib -Wl,-rpath=$zlib_dir/$zlib_lib"
    retval $? "hdf5 configure"
    make -j 2
    retval $? "hdf5 make"
    make check-s 2>&1 | tee hdf5.test
    retval $? "hdf5 make check-s"
    make install
    retval $? "hdf5 make install"
    mv hdf5.test $hdf_dir/
    cd ../../
    rm -rf hdf5-${h_v}
    echo "Completed installing hdf5"
    [ -d $hdf_dir/lib64 ] && hdf_lib=lib64 || hdf_lib=lib
else
    echo "hdf5 directory already found."
fi

####################
# Install NetCDF-C #
####################
if [ $_single_dir -eq 0 ]; then
    cdfc_dir=$ID/netcdf-c/$nc_v
else
    cdfc_dir=$ID
fi
[ -d $cdfc_dir/lib64 ] && cdfc_lib=lib64 || cdfc_lib=lib
if [ ! -e $cdfc_dir/$cdfc_lib/libnetcdf.a ]; then
    rm -rf netcdf-c-$nc_v
    tar xfz netcdf-c-$nc_v.tar.gz
    cd netcdf-c-$nc_v
    mkdir build ; cd build
    ../configure --prefix=$cdfc_dir \
	--enable-shared --enable-static \
	--enable-netcdf-4 --disable-dap \
	CPPFLAGS="-I$hdf_dir/include -I$zlib_dir/include" \
	LDFLAGS="-L$hdf_dir/$hdf_lib -Wl,-rpath=$hdf_dir/$hdf_lib \
-L$zlib_dir/$zlib_lib -Wl,-rpath=$zlib_dir/$zlib_lib"
    retval $? "netcdf configure"
    make -j 2
    retval $? "netcdf make"
    make install
    retval $? "netcdf make install"
    cd ../../
    rm -rf netcdf-c-$nc_v
    echo "Completed installing C NetCDF library"
    [ -d $cdfc_dir/lib64 ] && cdfc_lib=lib64 || cdfc_lib=lib
else
    echo "netcdf directory already found."
fi

##########################
# Install NetCDF-Fortran #
##########################
if [ $_single_dir -eq 0 ]; then
    cdff_dir=$ID/netcdf-fortran/$nc_v
else
    cdff_dir=$ID
fi
[ -d $cdff_dir/lib64 ] && cdff_lib=lib64 || cdff_lib=lib
if [ ! -e $cdff_dir/$cdff_lib/libnetcdff.a ]; then
    rm -rf netcdf-fortran-$nf_v
    tar xfz netcdf-fortran-$nf_v.tar.gz
    cd netcdf-fortran-$nf_v
    mkdir build ; cd build
    ../configure CPPFLAGS="-DgFortran -I$zlib_dir/include \
	-I$hdf_dir/include -I$cdfc_dir/include" \
	LIBS="-L$zlib_dir/$zlib_lib -Wl,-rpath=$zlib_dir/$zlib_lib \
	-L$hdf_dir/$hdf_lib -Wl,-rpath=$hdf_dir/$hdf_lib \
	-L$cdfc_dir/$cdfc_lib -Wl,-rpath=$cdfc_dir/$cdfc_lib \
	-lnetcdf -lhdf5hl_fortran -lhdf5_fortran -lhdf5_hl -lhdf5 -lz" \
	--prefix=$cdff_dir --enable-static --enable-shared
    retval $? "netcdf-fortran configure"
    make -j 2
    retval $? "netcdf-fortran make"
    make check 2>&1 | tee check.fortran.serial
    retval $? "netcdf-fortran make check"
    make install
    retval $? "netcdf-fortran make install"
    mv check.fortran.serial $cdff_dir/
    cd ../../
    rm -rf netcdf-fortran-$nf_v
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
# We only need the netcdf.mod file
echo "INCFLAGS += -I$cdfc_dir/include"
if [ $_single_dir -eq 0 ]; then
    echo "LDFLAGS += -L$zlib_dir/$zlib_lib -Wl,-rpath=$zlib_dir/$zlib_lib"
    echo "LDFLAGS += -L$hdf_dir/$hdf_lib -Wl,-rpath=$hdf_dir/$hdf_lib"
    echo "LDFLAGS += -L$cdfc_dir/$cdfc_lib -Wl,-rpath=$cdfc_dir/$cdfc_lib"
    echo "LDFLAGS += -L$cdff_dir/$cdff_lib -Wl,-rpath=$cdff_dir/$cdff_lib"
else
    # All have the same directory
    echo "LDFLAGS += -L$ID/$zlib_lib -Wl,-rpath=$ID/$zlib_lib"
fi
echo "LIBS += -lnetcdff -lnetcdf -lhdf5_hl -lhdf5 -lz"
echo "COMP_LIBS += libncdf.a libfdict.a"
echo "FPPFLAGS += -DCDF -DNCDF -DNCDF_4"
echo ""
