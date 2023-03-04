#!/bin/bash
#
# Compile script for QuicksilveR kernel
# Copyright (C) 2020-2021 Adithya R.
# (edits for CrystalCore kernel @dkpost3)

###############################   MISC   #################################

# functions
error() {
	telegram-send "Error⚠️: $*"
	exit 1
}

success() {
	telegram-send "Success: $*"
}

inform() {
	telegram-send --format html "$@"
}

muke() {
	if [[ -z $COMPILER || -z $COMPILER32 ]]; then
		error "Compiler is missing"
	fi
	if ! make $@ ${MAKE_ARGS[@]} $FLAG; then
		error "make failed"
	fi
}

##----------------------------------------------------------##

BOT_MSG_URL="https://api.telegram.org/bot$TOKEN/sendMessage"
BOT_BUILD_URL="https://api.telegram.org/bot$TOKEN/sendDocument"
SECONDS=0 # builtin bash timer
PROCS=$(nproc --all)
CI="Cirrus CI"
CHATID=${chat_id}
TOKEN=${token}

inform()
{
	curl -s -X POST "$BOT_MSG_URL" -d chat_id="$chat_id" \
	-d "disable_web_page_preview=true" \
	-d "parse_mode=html" \
	-d text="$1"

}

tg_post_build()
{
	#Post MD5Checksum alongwith for easeness
	MD5CHECK=$(md5sum "$1" | cut -d' ' -f1)

	#Show the Checksum alongwith caption
	curl --progress-bar -F document=@"$1" "$BOT_BUILD_URL" \
	-F chat_id="$CHATID"  \
	-F "disable_web_page_preview=true" \
	-F "parse_mode=Markdown" \
	-F caption="$2 | *MD5 Checksum : *\`$MD5CHECK\`"
}

##----------------------------------------------------------##

MODEL="Xiaomi 11 Lite 5G NE"
DEVICE="lisa"
ARCH=arm64
KERNEL_DIR=$(pwd)
TOOLCHAIN="$KERNEL_DIR/../toolchains"
TC_DIR="$TOOLCHAIN/clang"
export PATH="$TC_DIR/bin:$PATH"
AK3_DIR="$KERNEL_DIR/../AnyKernel3"
OUTPUT="$KERNEL_DIR/out"
DEFCONFIG="lisa_defconfig"
KBUILD_COMPILER_STRING=$("$TC_DIR"/bin/clang --version | head -n 1 | perl -pe 's/\(http.*?\)//gs' | sed -e 's/  */ /g' -e 's/[[:space:]]*$//')
MAKE_PARAMS1="ARCH=arm64 CC=$TC_DIR/bin/clang CLANG_TRIPLE=$TC_DIR/bin/aarch64-linux-gnu- LD=$TC_DIR/bin/ld.lld LLVM=1 LLVM_IAS=1 \
	CROSS_COMPILE=$TC_DIR/bin/llvm-"

# Set a commit head
COMMIT_HEAD=$(git log --oneline -1)

#Check Kernel Version
KV=$(make $MAKE_PARAMS1 kernelversion)

export KBUILD_BUILD_USER ARCH SUBARCH PATH \
		   KBUILD_COMPILER_STRING BOT_MSG_URL \
		   BOT_BUILD_URL PROCS

# shellcheck source=/etc/os-release
export DISTRO=$(source /etc/os-release && echo "${NAME}")
export KBUILD_BUILD_HOST=$(uname -a | awk '{print $2}')
export CI_BRANCH=$(git rev-parse --abbrev-ref HEAD)
TERM=xterm-256color

## Check for CI
if [ "$CI" ]
then
	if [ "$CIRCLECI" ]
	then
		export KBUILD_BUILD_VERSION=$CIRCLE_BUILD_NUM
		export KBUILD_BUILD_HOST="CircleCI"
		export CI_BRANCH=$CIRCLE_BRANCH
	fi
	if [ "$DRONE" ]
	then
		export KBUILD_BUILD_VERSION=$DRONE_BUILD_NUMBER
		export KBUILD_BUILD_HOST=$DRONE_SYSTEM_HOST
		export CI_BRANCH=$DRONE_BRANCH
		export BASEDIR=$DRONE_REPO_NAME
		export SERVER_URL="${DRONE_SYSTEM_PROTO}://${DRONE_SYSTEM_HOSTNAME}/${AUTHOR}/${BASEDIR}/${KBUILD_BUILD_VERSION}"
	else
		inform "##----------------------------------------------------------##"
	fi
fi

BLDV="R0.2-v0.0.1"
ZIPNAME="Proton-$BLDV.zip"
ZIPSIGNED="Proton-$BLDV-signed.zip"

MAKE_PARAMS="O=out ARCH=arm64 CC=$TC_DIR/bin/clang CLANG_TRIPLE=$TC_DIR/bin/aarch64-linux-gnu- LD=$TC_DIR/bin/ld.lld LLVM=1 LLVM_IAS=1 \
	CROSS_COMPILE=$TC_DIR/bin/llvm-"

export PATH="$TC_DIR/bin:$PATH"

make $MAKE_PARAMS mrproper
make $MAKE_PARAMS $DEFCONFIG
cp "$OUTPUT"/.config $KERNEL_DIR/arch/arm64/configs/lisa_defconfig
telegram-send --file "$KERNEL_DIR/out/.config"
inform "<b>Successfully regenerated defconfig at $DEFCONFIG</b>"


if [[ $1 = "-c" || $1 = "--clean" ]]; then
	rm -rf out
fi

mkdir -p out
make $MAKE_PARAMS $DEFCONFIG

inform "<b>$KBUILD_BUILD_VERSION CI Build Triggered</b>%0A<b>Docker OS: </b><code>$DISTRO</code>%0A<b>Kernel Version : </b><code>$KV</code>%0A<b>Date : </b><code>$(TZ=Asia/Jakarta date)</code>%0A<b>Device : </b><code>$MODEL [$DEVICE]</code>%0A<b>Pipeline Host : </b><code>$CI</code>%0A<b>Host Core Count : </b><code>$PROCS</code>%0A<b>Compiler Used : </b><code>$KBUILD_COMPILER_STRING</code>%0A<b>Linker : </b><code>$LINKER</code>%0a<b>Branch : </b><code>$CI_BRANCH</code>%0A<b>Top Commit : </b><code>$COMMIT_HEAD</code>%0A<a href='$SERVER_URL'>Link</a>"
inform "<b>Starting compilation</b>"
make -j$(nproc --all) $MAKE_PARAMS || exit $?
make -j$(nproc --all) $MAKE_PARAMS INSTALL_MOD_PATH=modules INSTALL_MOD_STRIP=1 modules_install

kernel="out/arch/arm64/boot/Image"
dtb="out/arch/arm64/boot/dts/vendor/qcom/yupik.dtb"
dtbo="out/arch/arm64/boot/dts/vendor/qcom/lisa-sm7325-overlay.dtbo"

if [ -f "$kernel" ] && [ -f "$dtb" ] && [ -f "$dtbo" ]; then
	inform "<b>Kernel compiled succesfully!</b>"
fi
	cp $kernel $AK3_DIR
	cp $dtb $AK3_DIR/dtb
	inform "<b>Creating DTBO Image</b>"
	python3 scripts/dtc/libfdt/mkdtboimg.py create $AK3_DIR/dtbo.img --page_size=4096 $dtbo
	cp $(find out/modules/lib/modules/5.4* -name '*.ko') $AK3_DIR/modules/vendor/lib/modules/
	cp out/modules/lib/modules/5.4*/modules.{alias,dep,softdep} $AK3_DIR/modules/vendor/lib/modules
	cp out/modules/lib/modules/5.4*/modules.order $AK3_DIR/modules/vendor/lib/modules/modules.load
	sed -i 's/\(kernel\/[^: ]*\/\)\([^: ]*\.ko\)/\/vendor\/lib\/modules\/\2/g' $AK3_DIR/modules/vendor/lib/modules/modules.dep
	sed -i 's/.*\///g' $AK3_DIR/modules/vendor/lib/modules/modules.load
	rm -rf out/arch/arm64/boot out/modules
	inform "<b>!Zipping Up!</b>"
	cd $AK3_DIR
	zip -r9 "$ZIPNAME" * -x ".git" -x ".github" -x "README.md" -x "*placeholder"
	telegram-send --file "${ZIPNAME}"
	inform "<b>!Completed in $((SECONDS / 60)) minute(s) and $((SECONDS % 60)) second(s)!</b>"
	cd ..
	exit
fi
