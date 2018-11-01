#!/bin/sh

set -ex

SOURCE_OUT=$PWD/$1
VERSION_OUT=$PWD/$2

test -z "$REPO" && { echo "REPO parameter must be supplied" >&2; exit 1; }

DIR=$(dirname $0)
source $DIR/../git/support/functions.sh
source $DIR/support/functions.sh

$DIR/../git/support/configure.sh

cd $SOURCE_OUT

git clone $REPO .
$DIR/../gitflow/support/configure.sh
git_track_remotes

VERSION=$(gitflow_require_release_version)
gitflow_checkout_release_branch

echo $VERSION > $VERSION_OUT/number
