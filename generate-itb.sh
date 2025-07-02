# usage: generate-itb.sh <absolute-path-binaries> <release>
# eg. generate-itb.sh /home/gcornacchia/projects/neutronic/kernel/releases/tz-003-testing tz-003-testing

FITPATH=./fit-image

sed 's@%PATH%@'"$1"'@g' $FITPATH/image-fmt.its > $FITPATH/image-fmt-new.its
$FITPATH/mkimage -f $FITPATH/image-fmt-new.its $1/image-$2.itb
rm $FITPATH/image-fmt-new.its
