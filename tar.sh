#!/bin/bash

tar cvfz TBT-TS-sisl.tar.gz \
    tutorial.pdf install_tutorial.sh \
    C.psf [01]*/*.{fdf,py,sh,psf} \
    */*/*.psf \
    siesta.pdf tbtrans.pdf \
    07/*.xyz

echo "  TBT-TS-sisl.tar.gz"
