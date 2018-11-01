#!/bin/sh

set -e

VERSION_IN=$PWD/$1
VERSION_OUT=$PWD/$2

test -z "$PRERELEASE" && { echo "Must supply PRERELEASE parameter" >&2; exit 1; }

VERSION=$(cat $VERSION_IN/number)

# TODO: replace existing prerelease

VERSION=$(echo "${VERSION}-$(echo $PRERELEASE | tr '-' '~')")

echo $VERSION
echo $VERSION > $VERSION_OUT/number
