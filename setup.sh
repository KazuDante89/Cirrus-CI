#!/usr/bin/env bash

pip3 install tg

KERNEL_SRC="$CWk_DIR/Kernel"
AK3_DIR="$KERNEL_SRC/AnyKernel3"

# Helper function for cloning: gsc = git shallow clone
gsc() {
	git clone --depth=1 -q $@
}

# Clone Neutron Clang
echo "Downloading Neutron Clang"
mkdir $CWk_DIR/clang
cd $CWk_DIR/clang
bash <(curl -s https://raw.githubusercontent.com/Neutron-Toolchains/antman/main/antman) -S=16012023
cd ../..

# Clone Kernel Source
echo "Downloading Kernel Source"
mkdir $KERNEL_SRC
gsc https://github.com/KazuDante89/android_kernel_ghost_lisa.git -b Proton_R0.3 $KERNEL_SRC
echo "Kernel Source Completed"

echo "Cloning AnyKernel3"
mkdir $AK3_DIR
gsc https://github.com/ghostrider-reborn/AnyKernel3.git -b lisa $AK3_DIR
echo "AnyKernel3 Completed"

# Copy script over to source
# cp $(pwd)/build.sh $KERNEL_SRC/build.#!/bin/sh
cd $KERNEL_SRC
wget -c https://raw.githubusercontent.com/KazuDante89/Cirrus-CI/main/build.sh -o build.sh

# Start build process
bash build.sh
# bash <(curl -s https://raw.githubusercontent.com/KazuDante89/Cirrus-CI/main/build.sh)
