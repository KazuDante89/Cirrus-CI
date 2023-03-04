#!/usr/bin/env bash

# Helper function for cloning: gsc = git shallow clone
gsc() {
	git clone --depth=1 -q $@
}

# Clone Neutron Clang
mkdir $CWk_DIR/clang
cd $CWk_DIR/clang
bash <(curl -s https://raw.githubusercontent.com/Neutron-Toolchains/antman/main/antman) -S=16012023
cd ../..

# Clone AnyKernel3
mkdir $AK3_DIR
gsc https://github.com/ghostrider-reborn/AnyKernel3.git -b lisa AnyKernel3

# Clone Kernel Source
mkdir $KERNEL_SRC
gsc https://github.com/KazuDante89/android_kernel_ghost_lisa.git -b Proton_R0.2 Kernel

# Move script to kernel source
mv build.sh Kernel/build.sh
cd Kernel

# Execute build script
bash build.sh
