#!/bin/bash

# Script to create output for multiple electrodes
# and/or multiple chemical potentials

_this=$(basename $0)

function error {
    echo "ERROR: something went wrong... Please see the following output:"
    while [ $# -gt 0 ]; do
	echo "$1"
	shift
    done
    exit 1
}


# We must require to be able to use the hash-able arrays
# This allows us to reuse the same input twice more easily
help=0
def=2
tbt=0
# Options about what to print
print_mu=0
print_el=0
print_c=0
declare -a opts
_N=0
volt=0
while [ $# -gt 0 ]; do
    opt=$1
    case $opt in
	--*)
	    opt=${1:1} ;;
    esac
    case $opt in
	-def|-orig|-original)
	    # Will produce output for standard TS
	    def=2 ; shift
	    ;;
	-V|-bias)
	    volt=$1 ; shift ; shift
	    ;;
	-1|-2|-3|-4|-5|-6|-7|-8|-9)
	    # Will produce output for standard TS
	    def=${opt:1} ; shift
	    ;;
	-only-el|-only-elec|-only-electrode)
	    print_el=1 ; shift
	    ;;
	-only-mu|-only-chem|-only-chemical)
	    print_mu=1 ; shift
	    ;;
	-only-c|-only-contour)
	    print_c=1 ; shift
	    ;;
	-T|-tbtrans)
	    # Prefix with TBT instead of TS
	    tbt=1 ; shift
	    ;;
	-help|-h)
	    # We need to print help
	    help=1 ; shift
	    ;;
	-*)
	    error "Unknown option: $opt"
	    ;;
	*)
	    break
    esac
done

# Correct what to print (if the user)
# has not specified anything
if [ $print_el -eq 0 ] && [ $print_mu -eq 0 ] && [ $print_c -eq 0 ]; then
    print_el=1
    print_mu=1
    print_c=1
fi

if [ $help -eq 1 ]; then
    fmt="      %20s : %s\n"
    echo "Usage:"
    echo "    $_this <options>"
    echo ""
    echo "For intrinsic transiesta runs call this:"
    echo "    $_this -2 -V <bias>"
    echo ""
    echo "If one wishes to divide it in several files do:"
    echo "    $_this -only-el > ELECS.fdf"
    echo "    $_this -only-mu > CHEMPOTS.fdf"
    echo "    $_this -only-c  > CONTOURS.fdf"
    echo ""
    echo "Only print out tbtrans related options:"
    echo "    $_this -T|--tbtrans"
    echo ""
    echo "For specifying the contour energy levels you can use these options:"
    printf "$fmt" "-Emin <val>" "band bottom energy in eV (-40. eV)"
    printf "$fmt" "-dE <val>" "real-axis distance between integration points (0.01 eV)"
    echo ""
    echo "There are preset creations of 2,3 and 4 electrodes, call:"
    echo "    $_this -[2-9]"
    echo "to create the equivalent systems, note that these options can be accompanied by further setup."
    echo ""
    echo "Available options for the chemical potentials:"
    echo "    -mu<idx>-X where X is one of the following:"
    printf "$fmt" "mu <val>" "the chemical potential value in eV, or in fractions of V (V/2, |V|/3, etc.)"
    printf "$fmt" "name <name>" "the name of the chemical potential (to be referenced by the electrodes)"
    echo ""
    echo "A shorthand notation for supplying the options is:"
    echo "    -mu<idx> Y=<val>,Z=<val> where Y,Z is one of X above"
    echo ""
    echo ""
    echo "Available options for the electrodes:"
    echo "    -el<idx>-X where X is one of the following:"
    printf "$fmt" "mu <name>" "the chemical potential name as given by -mu-name"
    printf "$fmt" "name <name>" "the name of the electrode"
    printf "$fmt" "tshs <file>" "the electrode TSHS-file"
    printf "$fmt" "semi-inf <val>" "the semi-infinite direction [-+][a-c|a[1-3]]"
    printf "$fmt" "pos <val>" "the first atom of the electrode in the structure"
    printf "$fmt" "end-pos <val>" "the last atom of the electrode in the structure"
    printf "$fmt" "used-atoms|ua <val>" "number of atoms used in the electrode (all)"
    printf "$fmt" "bloch-a[1-3] <val>" "the Bloch expansion in the equivalent direction (1)"
    printf "$fmt" "bulk <T|F>" "whether the electrode is a bulk electrode (true)"
    printf "$fmt" "gf <file>" "name of the Greens function file (TSGF[el<idx>-name])"
    echo ""
    echo "A shorthand notation for supplying the options is:"
    echo "    -el<idx> Y=<val>,Z=<val> where Y,Z is one of X above"
    echo ""
    echo "You can combine -2 with additional electrode options to easily generate different schemes"
    echo "To generate 3 electrodes and 2 chemical potentials you can do this:"
    echo "    $_this -2 -el3 name=Top,mu=Left,inf-dir=+a2,end-pos=-1"
    exit 1
fi

prefix=TS
# If we are doing tbtrans output
# we should not print the contour information
if [ $tbt -eq 1 ]; then
    prefix=TBT
    print_c=0
fi

# Add an option to the option array, enables easy creations
function add_opt {
    local rem=0
    [ "x$1" == "x-r" ] && rem=1 && shift
    local opt=$1 ; shift
    local val=$1 ; shift
    if [ $rem -eq 1 ]; then
	rem_opt $opt
    fi
    # array indices are zero-based
    local tmp=$(get_opt $opt 1)
    [ ${#tmp} -gt 0 ] && return 0
    opts+=($opt)
    opts+=($val)
    let _N++
    let _N++
}

# Removes an option from the option array, enables customization of the options in-code
function rem_opt {
    local opt=
    local i=
    while [ $# -gt 0 ]; do
	opt=$1 ; shift
	i=0
	while [ $i -le $_N ]; do
            local val=${opts[$i]}
            if [ "x$val" == "x$opt" ]; then
                #echo "Removing ($val|$opt: ${opts[$i]}"
                unset opts[$i]
                let i++
                #echo "Removing: ${opts[$i]}"
                unset opts[$i]
		break
            fi
            let i++
        done
    done
    opts=( "${opts[@]}" )
    _N=${#opts[@]}
}


# Lower-case function
function lc { printf "%b" "$@" | tr '[A-Z]' '[a-z]' ; }


function get_opt {
    # Returns the option from the array input
    # get_opt <opt-name (with ONE dash)> [number of arguments gobbled]
    # If [...] is 0:
    #   0) will return 0 or 1 whether or not the option exists
    #   1-9) will return the consecutive [...] number of elements
    local opt="$1" ; shift
    local count=0
    if [ $# -gt 0 ]; then
	count=$1 ; shift
    fi
    local i=0 ; local j=0
    local ret=""
    while [ $i -le $_N ]; do
	local oo=$(lc ${opts[$i]})
	#echo "searching for: $opt in $oo" 1>&2
	if [ "x$opt" == "x$oo" ]; then
	    if [ $count -gt 0 ]; then
		ret=""
		for j in `seq 1 $count` ; do
		    let i++
		    ret="$ret ${opts[$i]}"
		done
	    else
		ret=1
	    fi
	    break
	fi
	let i++
    done
    [ ${#ret} -eq 0 ] && [ $count -eq 0 ] && ret=0
    # trim white-space
    ret=${ret%% }
    ret=${ret## }
    printf "%b" "$ret"
}

# Expands the "short-hand" keywords to their full equivalents
function expand_key {
    local nm="$1" ; shift
    local i=1
    local reg_opt=
    local opt=
    local val=
    while : ; do
	reg_opt=$(get_opt -$nm$i 1)
	# If the option does not exist, we simply return
	[ ${#reg_opt} -eq 0 ] && [ $i -gt 6 ] && break
	# Delete, so that we only keep the wanted options (not necessary, but)
	rem_opt -$nm$i
	reg_opt="${reg_opt//,/ }"
	reg_opt="${reg_opt//;/ }"
        # Loop over comma/semi-colon separated entries
	for reg in $reg_opt ; do
            # Add to the option list
            # Retrive the option and value
	    opt=${reg%=*}
	    val=${reg#*=}
	    add_opt -r "-$nm$i-$opt" "$val"
	done
	let i++
    done
}

function reduce {
    local -a tmp
    local i=0
    local j=0
    while [ $j -le $_N ]; do
	if [ ${#opts[$j]} -gt 0 ]; then
	    tmp[$i]=${opts[$j]}
	    let i++
	fi
	let j++
    done
    opts=( "${tmp[@]}" )
    _N=$i
}

for i in `seq 1 $def` ; do
    # The user has requested a default setting for some electrodes
    # We add them to the option stack
    add_opt "-mu$i-name" "mu-$i"
    add_opt "-mu$i-mu" "<mu-mu$i>"
    add_opt "-el$i-name" "el-$i"
    add_opt "-el$i-mu" "mu-$i"
    add_opt "-el$i-pos" "<input-value>"
    add_opt "-el$i-semi-inf" "+a3"
done

# In case of only two electrodes we have
# the particular case of the traditional transiesta code
case $def in
    1)
	add_opt -r "-mu1-name" "single"
	add_opt -r "-mu1-mu" "0."
	add_opt -r "-el1-name" "single"
	add_opt -r "-el1-mu" "single"
	rem_opt -el1-pos -el1-end-pos -el1-semi-inf
	add_opt "-el1-pos" "1"
	add_opt "-el1-semi-inf" "-a3"
	;;
    2)
	add_opt -r "-mu1-name" "Left"
	add_opt -r "-mu1-mu" "V/2"
	add_opt -r "-el1-name" "Left"
	add_opt -r "-el1-mu" "Left"
	rem_opt -el1-pos -el1-end-pos -el1-semi-inf
	add_opt "-el1-pos" "1"
	add_opt "-el1-semi-inf" "-a3"
	add_opt -r "-mu2-name" "Right"
	add_opt -r "-mu2-mu" "-V/2"
	add_opt -r "-el2-name" "Right"
	add_opt -r "-el2-mu" "Right"
	rem_opt -el2-pos -el2-end-pos -el2-semi-inf
	add_opt "-el2-end-pos" "-1"
	add_opt "-el2-semi-inf" "+a3"
	;;
esac    


# Add the user options
while [ $# -gt 0 ]; do
    opt=$1 ; shift
    case $opt in
	--*)
	    opt=${1:1}
	    rem_opt $opt ;;
	-el*|-mu*)
	    rem_opt $opt ;;
    esac
    let _N++
    opts[$_N]="$opt"
done

# Expand again after the user things
expand_key mu
expand_key el
reduce


function count {
    local nm=$1 ; shift
    local n=0
    local i=
    local oldn=-1
    local opt=
    local j=
    while [ $oldn -ne $n ]; do
	oldn=$n
	i=$n
	let i++
	j=0
	while [ $j -lt $_N ]; do
	    opt=${opts[$j]}
	    case $opt in 
		-${nm}${i}*)
		    n=$i ;;
	    esac
	    let j++
	done
    done
    printf "%b" "$n"
}

# Save the options 
old_opts=( "${opts[@]}" )
i=0
while [ $i -lt $_N ]; do
    case ${opts[$i]} in
	-el*)
	    unset opts[$i]
	    let i++
	    unset opts[$i]
	    ;;
    esac
    let i++
done
# Remove empty array elements
reduce

# Energy for the contour
emin=$(get_opt -emin 1)
[ ${#emin} -eq 0 ] && emin=-40.
emin="$emin eV"
de=$(get_opt -de 1)
[ ${#de} -eq 0 ] && de=0.01



# The chemical potentials should be denoted like this option:
# -mu1 <options for the chemical potential in comma separated list>
# Another way of supplying information regarding the chemical potentials
#  -mu1-name <name>
#  -mu1-mu   <the value of the chemical potential>
_mus=$(count mu)
# First we need to figure out the number of chemical potentials:
# I don't suspect ANY user will go above 10 chemical potentials
[ $_mus -eq 0 ] && \
    error "You have zero chemical potentials." "Please supply at least one..."

# Create the chemical potential array
_mu_names=()
j=0
for i in `seq 1 $_mus` ; do
    _mu_names+=( "$(get_opt -mu$i-name 1)" )
    let j++
done

function mu_e_correct {
    local mu=$1 ; shift
    if [ "x${mu:0:1}" == "x-" ]; then
	# we have a negative sign
	if [ "x${mu:1:2}" != "x|V" ] && [ "x${mu:1:1}" != "xV" ]; then
	    mu="$mu eV"
	fi
    else
	if [ "x${mu:0:2}" != "x|V" ] && [ "x${mu:0:1}" != "xV" ]; then
	    mu="$mu eV"
	fi
    fi
    printf "%b" "$mu"
}
	
if [ $print_mu -eq 1 ]; then

# Print out chemical potential block:
echo "$prefix.Voltage $volt eV"
echo "%block $prefix.ChemPots"
for mu in ${_mu_names[@]} ; do
    echo "  $mu"
done
echo "%endblock $prefix.ChemPots"
echo ""


function create_mu {
    local mu=$1 ; shift
    local name=$(get_opt -mu$mu-name 1)
    if [ ${#name} -eq 0 ]; then
	error "Chemical potential: $mu" "Has not received a name (-mu$mu-name)"
    fi
    local chem=$(get_opt -mu$mu-mu 1)
    if [ ${#chem} -eq 0 ]; then
	error "Chemical potential: $mu" "Has not received a chemical potential value (-mu$mu-mu)"
    fi
    chem=$(mu_e_correct $chem)
    echo "%block $prefix.ChemPot.$name"
    echo "  mu $chem"
    if [ $tbt -eq 0 ]; then
	echo "  contour.eq"
	echo "    begin"
	echo "      C-$name"
	echo "      T-$name"
	echo "    end"
    fi
    echo "%endblock $prefix.ChemPot.$name"
}
for i in `seq 1 $_mus` ; do
    create_mu $i
done
fi

# Create all the contours

if [ $print_c -eq 1 ]; then

echo ""
echo "TS.Contours.Eq.Pole 2.5 eV"

for i in `seq 1 $_mus` ; do
    mu=$(get_opt -mu$i-name 1)
    # Create the contours
    echo "%block TS.Contour.C-$mu"
    echo "  part circle"
    e=$(get_opt -mu$i-mu 1)
    e=$(mu_e_correct $e)
    [ ${e:0:1} != "-" ] && e="+ $e"
    echo "   from $emin $e to -10 kT $e"
    echo "     points 25"
    echo "      method g-legendre"
    echo "%endblock TS.Contour.C-$mu"

    # Create the contours
    echo "%block TS.Contour.T-$mu"
    echo "  part tail"
    echo "   from prev to inf"
    echo "     points 10"
    echo "      method g-fermi"
    echo "%endblock TS.Contour.T-$mu"

done

echo ""
echo "MSG: You may need to correct the TS.Contours.nEq for signs of bias" >&2
echo "MSG: The energies must be in increasing order (you may use |V|/2 to designate absolute values)" >&2

if [ $_mus -gt 1 ]; then
    # Create the non-equilbrium contour
    echo "%block TS.Contours.nEq"
    for i in `seq 1 $_mus` ; do
	[ $i -eq $_mus ] && continue
	echo "  neq-$i"
    done
    echo "%endblock TS.Contours.nEq"
fi

# Create array of chemical potentials sorted
mus=()
j=1
for i in `seq $_mus -1 1` ; do
    tmp="$(get_opt -mu$i-mu 1)"
    tmp=${tmp//\|V\|/V}
    tmp=${tmp//V/\|V\|}
    mus[$j]=$(mu_e_correct $tmp)
    let j++
done


# Create the contours
if [ $_mus -gt 2 ]; then
    echo "MSG: You can do with a single contour line in the bias window" >&2
    echo "MSG: Use the lowest bias to the highest bias." >&2
    echo "MSG: Here we supply as many different parts as there are chemical potentials" >&2
fi

if [ $_mus -gt 1 ]; then

    i=1
    echo "%block TS.Contour.nEq.neq-$i"
    echo "  part line"
    j=$((i+1))
    if [ $j -eq $_mus ]; then
	echo "   from ${mus[$i]} - 5 kT to ${mus[$j]} + 5 kT"
    else
	echo "   from ${mus[$i]} - 5 kT to ${mus[$j]}"
    fi
    echo "     delta $de eV"
    echo "      method mid-rule"
    echo "%endblock TS.Contour.nEq.neq-$i"

    # Sort all chemical potentials
    for i in `seq 3 $((_mus))` ; do
	# Create the contours
	echo "%block TS.Contour.nEq.neq-$((i-1))"
	echo "  part line"
	if [ $i -eq $_mus ]; then
	    echo "   from prev to ${mus[$i]} + 5 kT"
	else
	    echo "   from prev to ${mus[$i]}"
	fi
	echo "     delta $de eV"
	echo "      method mid-rule"
	echo "%endblock TS.Contour.nEq.neq-$((i-1))"
    done
fi

fi



# Recreate the old 
opts=( "${old_opts[@]}" )
_N=${#opts[@]}
# remove all mu
i=0
while [ $i -lt $_N ]; do
    case ${opts[$i]} in
	-mu*)
	    unset opts[$i]
	    let i++
	    unset opts[$i] ;;
    esac
    let i++
done
# Remove empty things
reduce


# Now we will concentrate on the electrodes
# First we need to figure out the number of electrode
# I don't suspect ANY user will go above 10 electrodes
_els=$(count el)
[ $_els -eq 0 ] && \
    error "You have zero electrodes." "Please supply at least one..."
[ $_els -lt $_mus ] && \
    error "You have fewer electrodes than chemical potentials." "Please correct your input..."


if [ $print_el -eq 1 ]; then

# Print out electrodes block:
echo ""
echo "%block $prefix.Elecs"
for i in `seq 1 $_els` ; do
    echo "  $(get_opt -el$i-name 1)"
done
echo "%endblock $prefix.Elecs"
echo ""

# Get whether or not we should print everything    
_all=$(get_opt -print-all)
[ $_all -eq 0 ] && _all=$(get_opt -el-all)


function create_el {
    local el=$1 ; shift
    local name=$(get_opt -el$el-name 1)
    [ ${#name} -eq 0 ] && error "Electrode: $el" "Has not received a name (-el$el-name)"
    local chem=$(get_opt -el$el-mu 1)
    [ ${#chem} -eq 0 ] && error "Electrode: $el" "Has not received a chemical potential reference (-el$el-mu)"
    # Currently we don't check for the existance of
    # the chemical potential.
    local found=0
    local i=$_mus
    let i--
    for j in `seq 0 $i` ; do
	if [ "x${_mu_names[$j]}" == "x$chem" ]; then
	    found=1
	fi
    done
    [ $found -ne 1 ] && error "Electrode: $el could not be associated with a matching chemical potential: $chem"
    echo "%block $prefix.Elec.$name"
    local tshs=$(get_opt -el$el-tshs 1)
    
    if [ ${#tshs} -ne 0 ]; then
	echo "  HS $tshs"
    else
	echo "  HS <input file>"
    fi
    echo "  chemical-potential $chem"
    echo "  semi-inf-direction $(get_opt -el$el-semi-inf 1)"
    local pos=$(get_opt -el$el-pos 1)
    if [ ${#pos} -eq 0 ]; then
	pos=$(get_opt -el$el-end-pos 1)
	[ ${#pos} -ne 0 ] && pos="end $pos"
    fi
    [ ${#pos} -eq 0 ] && pos="<set value>"
    echo "  electrode-position $pos"
    # Now we can set all the other things (non-important)
    function print_if {
	local opt=
	for opt in ${1//:/ } ; do
	    local val=$(get_opt -el$el-$opt 1)
	    if [ ${#val} -gt 0 ]; then
		echo "  $2 $val"
		break
	    fi
	done
    }
    print_if used-atoms:ua "used-atoms"
    print_if bloch-a:bloch-a1 "bloch-a1"
    print_if bloch-b:bloch-a2 "bloch-a2"
    print_if bloch-c:bloch-a3 "bloch-a3"
    print_if bulk "bulk"
    print_if gf "GF"
    echo "%endblock $prefix.Elec.$name"
}
for i in `seq 1 $_els` ; do
    create_el $i
done

fi


# Recreate the options
opts=( "${old_opts[@]}" )
_N=${#opts[@]}

