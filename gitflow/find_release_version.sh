#!/bin/sh

set -ex

SOURCE=$PWD/$1
VERSION_OUT=$PWD/$2

cd $SOURCE

VERSION=$(gitflow_find_release_version)

echo "Found release version: ${VERSION}"

echo $VERSION > $VERSION_OUT/number
