# usage: generate-itb.sh <absolute-path-binaries> <release>
# eg. generate-itb.sh /home/gcornacchia/projects/neutronic/kernel/releases/tz-003-testing tz-003-testing

FITPATH=fit-image

cd $FITPATH

sed 's@%PATH%@'"$1"'@g' image-fmt.its > image-fmt-new.its
mkimage -f image-fmt-new.its $1/image-$2.itb
rm image-fmt-new.its
