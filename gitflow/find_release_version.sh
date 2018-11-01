#!/bin/sh

set -ex

SOURCE=$PWD/$1
VERSION_OUT=$PWD/$2

cd $SOURCE

VERSION=$(gitflow_find_release_version)

if [ -z "$VERSION" ]; then
  echo "Release branch not found"
  test "$REQUIRE" = "true" && exit 1
else
  echo "Found release version: ${VERSION}"
  echo $VERSION > $VERSION_OUT/number
fi
