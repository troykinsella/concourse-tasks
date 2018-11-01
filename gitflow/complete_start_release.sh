#!/bin/sh

set -ex

VERSION_DIR=$PWD/$1
SOURCE_IN=$PWD/$2

DIR=$(dirname $0)
source $DIR/../git/support/functions.sh
source $DIR/support/functions.sh

cd $SOURCE_IN

VERSION=$(cat $VERSION_DIR/number)

git_ensure_branch $(gitflow_release_branch_name)

git flow release publish --showcommands $VERSION

echo "Published $(gitflow_release_branch_name)"
