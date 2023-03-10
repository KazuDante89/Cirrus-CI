KERNEL_SRC="$CWk_DIR"/Kernel
AK3_DIR="$KERNEL_SRC"/AnyKernel3
OUTPUT="$KERNEL_SRC"/out
UPLOADFOLDER="$CWk_DIR"/upload

export KERNEL_SRC AK3_DIR OUTPUT UPLOADFOLDER

# Helper function for cloning: gsc = git shallow clone
gsc() {
	git clone --depth=1 -q $@
}

# Clone Neutron Clang
echo "Downloading Neutron Clang"
mkdir $CWk_DIR/clang
cd $CWk_DIR/clang
bash <(curl -s https://raw.githubusercontent.com/Neutron-Toolchains/antman/main/antman) -S=latest
cd ../..

# Clone Kernel Source
echo "Downloading Kernel Source"
mkdir $KERNEL_SRC
gsc https://github.com/KazuDante89/android_kernel_ghost_lisa.git -b Proton_R0.6 $KERNEL_SRC
echo "Kernel Source Completed"

echo "Cloning AnyKernel3"
mkdir $AK3_DIR
gsc https://github.com/ghostrider-reborn/AnyKernel3.git -b lisa $AK3_DIR
echo "AnyKernel3 Completed"

# Uploading directory
echo "Create Upload directory"
mkdir $UPLOADFOLDER

# Copy script over to source
cd $KERNEL_SRC
bash <(curl -s https://raw.githubusercontent.com/KazuDante89/Cirrus-CI/main/build.sh)
