#!/bin/sh

set -ex

VERSION_DIR=$PWD/$1
SOURCE_IN=$PWD/$2

DIR=$(dirname $0)
source $DIR/../git/support/functions.sh
source $DIR/support/functions.sh

cd $SOURCE_IN

export GIT_MERGE_AUTOEDIT=no
git flow release finish --showcommands -p -D -m "chore(release): Release $VERSION"
unset GIT_MERGE_AUTOEDIT
