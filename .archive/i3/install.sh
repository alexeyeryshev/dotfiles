#!/usr/bin/env bash
set -x

SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd -P )"
echo $SCRIPTPATH
ln -s $SCRIPTPATH ~/.config/i3
pushd ~/.config/i3/tools/xkblayout-state
make
popd
