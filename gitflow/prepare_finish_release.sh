#!/bin/sh

set -ex

SOURCE_OUT=$PWD/$1

test -z "$REPO" && { echo "REPO parameter must be supplied" >&2; exit 1; }

DIR=$(dirname $0)
source $DIR/../git/support/functions.sh
source $DIR/support/functions.sh

$DIR/../git/support/configure.sh

cd $SOURCE_OUT

git clone $REPO .
$DIR/../gitflow/support/configure.sh
git_track_remotes

git checkout $(gitflow_release_branch_name)
