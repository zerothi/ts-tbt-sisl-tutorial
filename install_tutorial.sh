#!/bin/bash

set -e

url=www.student.dtu.dk/~nicpa/sisl/workshop/23
indir=$HOME/TBT-TS-sisl-workshop
# We install miniconda in the $indir
# Hence we don't need an enviroment, we just have it here
# as a place-holder.
env_name="2023-workshop-ts-sisl"


if command -v wget &> /dev/null ; then
  function download_file {
    local url=$1
    local out=$2
    shift 2
    wget -O $out $url
    local retval=$?
    if [ $retval -ne 0 ]; then
        echo "Failed to download: $url to $out"
    fi
    return $retval
  }
elif command -v curl &> /dev/null ; then
  function download_file {
    local url=$1
    local out=$2
    shift 2
    curl -k -o $out -LO $url
    local retval=$?
    if [ $retval -ne 0 ]; then
        echo "Failed to download: $url to $out"
    fi
    return $retval
  }
else
  echo "Cannot find either wget or curl command, please install one of them on your machine"
  exit 1
fi

function _help {
  echo "This script may be used to install the dependencies for the"
  echo "tutorial such as Python, numpy, scipy, matplotlib, jupyter and sisl and hubbard."
  echo ""
  echo "This script is a two-step script. Please read below."
  echo ""
  echo "Running this script in installation mode will download and install conda"
  echo "conda provides both Siesta executables as well as the sisl and dependency packages"
  echo "so once installed all required infrastructure is available."
  echo "It does, however, require a disk space of approximately >4GB"
  echo ""
  echo "To use the conda framework, run this script in installation mode:"
  echo ""
  echo "  $0 install"
  echo ""
  echo "If you can install Siesta (master version) and sisl 0.14.3 and the rest of the dependencies"
  echo "manually then you won't be needing the above installation procedure."
  echo "However, we cannot assist installing the packages manually."
  echo ""
  echo "Once the above step is fulfilled you should run the download part"
  echo "of the script. It will download the required files for the tutorial:"
  echo ""
  echo "  $0 download"
  echo ""
}

if [ $# -eq 0 ]; then
  _help
  exit 1
fi

# First we get the current directory
cwd=$(pwd)

# Figure out if we are dealing with UNIX or MacOS
os=$(uname -s)
arch=$(uname -m)
case "${os}" in
    Linux|Darwin)
	    ;;
    *)
      echo "Are you using MingGW or FreeBSD? Or a (${os})?"
      echo "Either way this installation script does not work for your distribution..."
      exit 1
      ;;
esac

action=install
case $1 in
    install)
      # do nothing, we use the OS to determine stuff
      action=install
      ;;
    update)
      # Update this script
      # Try and update
      base=$(basename $0)
      cp $cwd/$0 $cwd/old_$base
      download_file $url/install_tutorial.sh $cwd/new_$base
      if [ $? -eq 0 ]; then
          mv $cwd/new_$base $cwd/$base
          chmod u+x $cwd/$base
          echo ""
          echo "Successfully updated script..."
          rm $cwd/old_$base
      fi
      exit 0
      ;;
    download)
      action=download
      ;;
    *)
      echo "###########################################"
      echo "# Unknown argument: $1"
      echo "#"
      echo "# Should be either 'install', 'update' or 'download'"
      echo "#"
      echo "###########################################"
      echo ""
      _help
      exit 1
      ;;
esac


function conda_install {
    local exe=$1 ; shift

    if [ ! -e $indir/miniconda3/bin/activate ]; then
      if [ ! -e $exe ]; then
        download_file https://repo.anaconda.com/miniconda/$exe $exe
        [ $? -ne 0 ] && exit 1
      fi
      sh ./$exe -b -s -f -p $indir/miniconda3
      source $indir/miniconda3/bin/activate
      conda update -y -n base conda
    else
      source $indir/miniconda3/bin/activate
    fi

    if [[ ${arch} == "arm64" ]]; then
      # see https://github.com/conda-forge/miniforge/issues/165#issuecomment-860233092
      # This should use rosetta under the hood, if not
      # then open a terminal by emulating x86-64
      conda config --env --set subdir osx-64
    fi

    local -a packages=
    packages=(
      "python<3.12"
      "siesta=5.0.0rc1=*openmpi*"
      "sisl=0.14.3"
      "netCDF4"
      "jupyter"
      "pyamg"
      "pathos"
      "matplotlib"
      "plotly"
      "scikit-image"
      "py3dmol"
    )

    # install everything
    conda install -y -c conda-forge/label/siesta_rc -c conda-forge ${packages[@]}
    [ $? -ne 0 ] && { echo "failed" ; exit 1; }

    # remove unused tarballs (no need for them to be around)
    conda clean -t -y
    {
    echo "#!/bin/bash"
    echo "source $indir/miniconda3/bin/activate"
    echo "export OMPI_MCA_btl='vader,self'"
    } > $indir/setup.sh

    source $indir/setup.sh

    # hubbard
    local v=0.4.1
    download_file https://github.com/dipc-cc/hubbard/archive/refs/tags/v$v.tar.gz hubbard-$v.tar.gz
    [ $? -ne 0 ] && exit 1
    tar xfz hubbard-$v.tar.gz
    cd hubbard-$v
    python -m pip install .
    [ $? -ne 0 ] && exit 1
    cd ../
    rm -rf hubbard-$v hubbard-$v.tar.gz

    echo ""
    echo "Before you can run exercises etc. you should execute the following:"
    echo ""
    echo " source $indir/setup.sh"
    echo ""
}

# Function for installation on Linux
function linux_install {
  conda_install Miniconda3-latest-Linux-${arch}.sh
}


function macos_install {
  if [[ ${arch} == "arm64" ]]; then
    export CONDA_SUBDIR=osx-64
  fi
  conda_install Miniconda3-latest-MacOSX-${arch}.sh
}

function install_warning {
    echo "RUNNING THIS SCRIPT IS AT YOUR OWN RISK!!!"
    echo "THIS SCRIPT IS MADE FOR HELPFUL PURPOSE, BUT YOU ARE"
    echo "RESPONSIBLE FOR ANY ERRORS/DATALOSSES THIS SCRIPT MAY INFER."
    echo "IF YOU DO NOT WANT TO RUN THIS SCRIPT PRESS:"
    echo ""
    echo "  CTRL+^C"
    echo ""
    echo "Please ensure you have more than 5 GB of disk space available!"
    echo ""
    sleep 3
}

# Now create a common folder in the top-home directory

function download_warning {
    echo ""
    echo "This script will create a folder in your $HOME directory:"
    echo "  $HOME/TBT-TS-sisl-workshop"
    echo "where all the tutorials and executable files will be downloaded."
    echo ""
}

function install_test_sisl {
    echo ""
    echo " Will try and run sisl and hubbard"
    local cmd="import sisl ; print(sisl.__file__, sisl.__version__)"
    echo "    import sisl ; print(sisl.__file__, sisl.__version__)"
    cmd="$cmd ; import hubbard ; print(hubbard.__file__)"
    echo "    import sisl.viz"
    cmd="$cmd ; import sisl.viz"

    python -c "$cmd"
    if [ $? -ne 0 ]; then
	echo "Failed running sisl, please mail the organizer with the error message (unless some of the installations failed)"
    fi
}

# create installation directory
mkdir -p $indir
pushd $indir

if [ $action == install ]; then
    # os will be download
    download_warning
    install_warning
    case $os in
      Linux)
        linux_install
	    ;;
      Darwin)
        macos_install
	    ;;
    esac
    install_test_sisl

    exit 0
else
    download_warning
fi


# Download latest tutorial files
mkdir -p tarball
for file in sisl-TBT-TS.tar.gz hubbard-tutorials.tar.gz xabier-tutorials.tar.gz
do
  if [ -e tarball/$file ]; then
    rm tarball/$file
  fi
  download_file $url/$file tarball/$file
  [ $? -ne 0 ] && exit 1
done
{
    echo "Please be careful about extracting these tarballs."
    echo "If you extract them on top of tutorials you have already"
    echo "completed, you will overwrite any progress made!"
    echo "Please untar in a fresh directory and move the files you need."
} > tarball/README

mkdir -p presentations
for file in talk_1.pdf talk_3.pdf talk_4.pdf RSSE.pdf
do
  if [ -e presentations/$file ]; then
    rm presentations/$file
  fi
  download_file $url/$file presentations/$file
  [ $? -ne 0 ] && exit 1
done

echo ""
echo "In folders"
echo "   $indir"
echo "   $indir/tarball"
echo "   $indir/presentations"
echo "you will find everything needed for the tutorial."
echo "If you are using the conda installation provided by this script"
echo "please always start your sessions by executing:"
echo ""
echo "  source $indir/setup.sh"
echo ""
echo "which will correctly setup the environment for you."
echo "Run (after you have restarted your shell):"
echo "  which tbtrans"
echo "and check it returns $indir/miniconda3/bin/tbtrans"
