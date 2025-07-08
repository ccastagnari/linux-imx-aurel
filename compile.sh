#bypass check for LD_LIBRARY_PATH **ONLY** if thinlinc session is active
TL=$(echo $LD_LIBRARY_PATH | grep thinlinc)
if [ ! -z $TL ]; then
	unset LD_LIBRARY_PATH
fi

#source the yocto environment
. /opt/oecore-x86_64/environment-setup-cortexa7t2hf-neon-oe-linux-gnueabi

message() {
        echo -e '\E[1;33m'$1'\E[0m'
}

compile_dts() {
        # make ARCH=arm imx6ull-var-dart-6ulcustomboard-emmc-sd-card.dtb
        # make ARCH=arm imx6ull-var-dart-6ulcustomboard-emmc-wifi-brcm.dtb
        # make ARCH=arm imx6ull-var-dart-6ulcustomboard-nand-sd-card.dtb
        make ARCH=arm imx6ull-var-dart-6ulcustomboard-nand-wifi-brcm.dtb
        cp arch/arm/boot/dts/imx6ull-var-dart*.dtb $2
}

if [ "$1" = "netboot" ]; then
	message "Compiling [netboot] version"
	CFG=imx_v7_neutronic_netboot_defconfig
elif [ ! -z "$1" ]; then
	echo opzione non riconosciuta [$1]
	exit
else
	CFG=imx_v7_neutronic_defconfig
fi

echo $CFG > .target
make $CFG

BUILDVER=$(cat .config | grep LOCALVERSION | awk -F'"' '{print substr($2,2)}')
OUTPUTDIR=build/$BUILDVER
rm -rf $OUTPUTDIR
mkdir -p $OUTPUTDIR

mkdir -p build/modules/
rm -rf arch/arm/boot/zImage

make -j4 zImage
if [ -z arch/arm/boot/zImage ]; then
        message "zImage missing!"
        exit
fi

compile_dts some-cfg $OUTPUTDIR

cp arch/arm/boot/zImage $OUTPUTDIR

if [ "$1" = "netboot" ]; then
	pushd $OUTPUTDIR
	ln -s imx6ull-var-dart-6ulcustomboard-emmc-wifi.dtb imx6ull-var-dart-5g-emmc_wifi.dtb
	ln -s imx6ull-var-dart-6ulcustomboard-nand-wifi.dtb imx6ull-var-dart-5g-nand_wifi.dtb
	popd
else
	# build modules
	rm -rf ./build/modules
	make ARCH=arm -j4 modules INSTALL_MOD_PATH=./build/modules
	make ARCH=arm -j4 modules_install INSTALL_MOD_PATH=./build/modules
	tar -C ./build/modules -czf $OUTPUTDIR/modules_$BUILDVER.tgz .
	
	#create itb
	./generate-itb.sh $PWD/$OUTPUTDIR $BUILDVER
fi

message "Output folder: $OUTPUTDIR"
ls -la $OUTPUTDIR
