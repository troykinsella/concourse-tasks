#!/usr/bin/env bash

set -e

VOLUME=$PWD/$1
cd $VOLUME

test -n "$DIR" && cd $DIR

ls -altR
