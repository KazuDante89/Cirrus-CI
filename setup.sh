#!/usr/bin/env bash

# Install pigz
pacman -Sy --needed --noconfirm pigz

# Helper function for cloning: gsc = git shallow clone
gsc() {
	git clone --depth=1 -q $@
}

# Toolchains directory
mkdir toolchains

# Clone GCC
gsc https://github.com/mvaisakh/gcc-arm.git -b gcc-master toolchains/gcc32

# Clone Neutron Clang
mkdir toolchains/clang && cd toolchains/clang
bash <(curl -s https://raw.githubusercontent.com/Neutron-Toolchains/antman/main/antman) -S=latest
cd ../..

# Clone AnyKernel3
gsc https://github.com/ghostrider-reborn/AnyKernel3.git -b lisa AnyKernel3

# Clone Kernel Source
gsc https://github.com/KazuDante89/android_kernel_ghost_lisa.git -b Proton_R0.3 Kernel

# Move script to kernel source
mv build.sh Kernel/build.sh
cd Kernel

# Execute build script
bash build.sh
