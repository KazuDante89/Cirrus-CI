#!/usr/bin/env bash

pip3 -q install telegram-send

sed -i s/demo1/"${token}"/g telegram-send.conf
sed -i s/demo2/"${chat_id}"/g telegram-send.conf
mkdir "$HOME"/.config
mv telegram-send.conf "$HOME"/.config/telegram-send.conf

KERNEL_SRC="$CWk_DIR/Kernel"
AK3_DIR="$CWk_DIR/AnyKernel3"

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

echo "Cloning AnyKernel3"
mkdir $AK3_DIR
gsc https://github.com/ghostrider-reborn/AnyKernel3.git -b lisa $AK3_DIR

# Clone Kernel Source
mkdir $KERNEL_SRC
echo "Downloading Kernel Source.."
gsc https://github.com/KazuDante89/android_kernel_ghost_lisa.git -b Proton_R0.3 $KERNEL_SRC

# Start build process
cd $KERNEL_SRC
bash <(curl -s https://raw.githubusercontent.com/KazuDante89/Cirrus-CI/main/build.sh)
