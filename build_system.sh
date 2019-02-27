#!/bin/bash
################################################################
##
##
##
################################################################
set -e

if [ -z $ROOT ]; then
	ROOT=`cd .. && pwd`
fi

OUTPUT="$ROOT/output"

PRELOADERBIN=$OUTPUT/preloader/bin/preloader_bd6737m_35g_b_m0.bin
LKBIN=$OUTPUT/lk/build-bd6737m_35g_b_m0/lk.bin
LOGOBIN=$OUTPUT/lk/build-bd6737m_35g_b_m0/logo.bin
KERNEL=$OUTPUT/kernel/arch/arm/boot/zImage-dtb
BOOTIMG=$OUTPUT/system/boot.img

if [ ! -f $PRELOADERBIN -o ! -f $LKBIN ]; then
	echo "Please build lk"
	exit 0
fi
if [ ! -f $KERNEL ]; then
	echo "Please build linux"
	exit 0
fi

if [ ! -d $ROOT/output/system ]; then
	mkdir -p $ROOT/output/system
fi

set -x

echo -e "\e[36m Prepare bootloader image\e[0m"
cp $PRELOADERBIN $OUTPUT/system
cp $LKBIN $OUTPUT/system
cp $LOGOBIN $OUTPUT/system

echo -e "\e[36m Generate Boot image start\e[0m"
$ROOT/external/mkbootimg \
	--kernel $KERNEL \
	--cmdline bootopt=64S3,32N2,32N2 --base 0x40000000  \
	--ramdisk_offset 0x04000000 --kernel_offset 0x00008000 \
	--tags_offset 0xE000000 --board 1551082161 \
	--kernel_offset 0x00008000 --ramdisk_offset 0x04000000 \
	--tags_offset 0xE000000 --output $OUTPUT/system/boot.img
echo -e "\e[36m Generate Boot image : ${BOOTIMG} success! \e[0m"

cp $ROOT/external/system/*  $OUTPUT/system
sync
set +x
clear

