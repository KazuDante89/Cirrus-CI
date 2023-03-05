#!/usr/bin/env bash

# Install pigz
echo "Installing PIGZ"
pacman -Sy --needed --noconfirm pigz

# Install telegram-cli
echo "Installing Telegram-CLI"
yay -S --noconfirm telegram-cli-git

KERNEL_SRC="$CWk_DIR/Kernel"
AK3_DIR="$KERNEL_SRC/AnyKernel3"
TOKEN=$token
CHATID=$chat_id
BOT_MSG_URL="https://api.telegram.org/bot$TOKEN/sendMessage"
BOT_BUILD_URL="https://api.telegram.org/bot$TOKEN/sendDocument"
SECONDS=0 # builtin bash timer
PROCS=$(nproc --all)
CI="Cirrus CI"

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
cd $KERNEL_SRC
bash <(curl -s https://raw.githubusercontent.com/KazuDante89/Cirrus-CI/main/build.sh)
