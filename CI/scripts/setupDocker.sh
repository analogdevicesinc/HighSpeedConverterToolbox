#!/bin/bash
# This file is run inside of the docker container
ifconfig eth0 hw ether "$ADDR"
echo "Copying HSP files"
cp -r /mlhspro /mlhsp
echo "Copying .matlab"
cp -r /root/.matlabro /root/.matlab
echo "Copying .Xilinx"
cp -r /root/.Xilinxro /root/.Xilinx
