#!/bin/sh

set -e

OUT=$PWD/$1

test -z "$REPO" && { echo "REPO parameter must be supplied" >&2; exit 1; }

DIR=$(dirname $0)
source $DIR/support/functions.sh
$DIR/support/configure.sh

cd $OUT

echo "Cloning $REPO"
git clone $REPO .
git_track_remotes

if [ "$GIT_FLOW" = "true" ]; then
  $DIR/../gitflow/support/configure.sh
fi

if [ -n "$BRANCH" ]; then
  echo "Checking out branch: $BRANCH"
  git checkout $BRANCH
fi

echo "Git status:"
git status
