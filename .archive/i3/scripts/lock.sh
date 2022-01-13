#!/usr/bin/env bash
ICON=$HOME/.config/i3/images/casual_lock.png

TEMPDIR=/tmp

sh $HOME/.config/i3/scripts/individual_scrot.sh

convert $TEMPDIR/head_0.png -scale 10% -scale 1000% $TEMPDIR/head_0.png
[[ -f $ICON ]] && convert $TEMPDIR/head_0.png $ICON -gravity center -composite -matte $TEMPDIR/head_0.png
if [ -e $TEMPDIR/head_1.png ]; then
  convert $TEMPDIR/head_1.png -scale 10% -scale 1000% $TEMPDIR/head_1.png
  [[ -f $ICON ]] && convert $TEMPDIR/head_1.png $ICON -gravity center -composite -matte $TEMPDIR/head_1.png
  convert $TEMPDIR/head_1.png $TEMPDIR/head_0.png +append $TEMPDIR/screen.png
else
  mv $TEMPDIR/head_0.png $TEMPDIR/screen.png
fi


i3lock -i $TEMPDIR/screen.png
rm $TEMPDIR/screen.png $TEMPDIR/head_*.png
