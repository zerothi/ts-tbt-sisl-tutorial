#!/bin/bash

# This small script will compile and upload the executables to the
# website
base=$(pwd)
SIESTA_DIR=/home/nicpa/siesta/siesta
year=20

_obj=ObjTutorial$year

# First download and compile NetCDF
_ncdf_prefix=/home/nicpa/siesta/netcdf-serial
./install_netcdf4.bash -p $_ncdf_prefix --single-directory
[ $? -ne 0 ] && exit 1

pushd $SIESTA_DIR

# Prepare directory (ensure it is clean)
rm -rf $_obj
mkdir -p $_obj
cd $_obj

# Ensure arch.make exists
[ ! -e $base/static_gnu.make ] && echo "Failed to find static_gnu.make" && exit 1
ln -s $base/static_gnu.make arch.make

../Src/obj_setup.sh

function mmake {
    local base=$1
    shift
    local suffix=$1
    shift
    make clean
    make -j4 INSTALL_NCDF4_PATH=$_ncdf_prefix $@
    [ $? -ne 0 ] && exit 1
    scp $base tr:.p/sisl/workshop/$year/$base$suffix
    [ $? -ne 0 ] && exit 1
}

mmake siesta ""
mmake siesta _sse USE_SSE=1
mmake siesta _avx USE_AVX=1
mmake siesta _avx2 USE_AVX2=1

cd ../Util/TS/TBtrans

mmake tbtrans "" OBJDIR=$_obj
mmake tbtrans _sse OBJDIR=$_obj USE_SSE=1
mmake tbtrans _avx OBJDIR=$_obj USE_AVX=1
mmake tbtrans _avx2 OBJDIR=$_obj USE_AVX2=1

popd

