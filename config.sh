[ ! -f .target ] && echo "target undefined, run ./compile.sh" && exit

CFG=$(cat .target)
make ARCH=arm xconfig
make ARCH=arm savedefconfig
cp defconfig arch/arm/configs/$CFG