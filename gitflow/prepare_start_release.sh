#!/bin/sh

set -ex

VERSION_DIR=$PWD/$1
SOURCE_OUT=$PWD/$2

test -z "$REPO" && { echo "REPO parameter must be supplied" >&2; exit 1; }

DIR=$(dirname $0)
source $DIR/../git/support/functions.sh
source $DIR/support/functions.sh

$DIR/../git/support/configure.sh

cd $SOURCE_OUT

VERSION=$(gitflow_find_release_version)

git clone $REPO .
$DIR/../gitflow/support/configure.sh
git_track_remotes

if [ -z "$VERSION" ]; then
  VERSION=$(cat $VERSION_DIR/number)
  echo "No release branch found. Will branch develop into $(gitflow_release_branch_name)."
  git checkout develop
  git flow release start --showcommands $VERSION
else
  echo "Found existing release branch: $(gitflow_release_branch_name). Will merge develop."
  git checkout $(gitflow_release_branch_name)
  git merge origin develop
fi
