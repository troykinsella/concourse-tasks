#!/usr/bin/env bash

set -e

BRANCH_FILE_SOURCE="$PWD/$1"
OUT="$PWD/$2"

test -z "$REPO" && { echo "REPO parameter must be supplied" >&2; exit 1; }

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" > /dev/null && pwd)"
source $DIR/support/functions.sh
$DIR/support/configure.sh

cd $OUT

echo "Cloning $REPO"
git clone "$REPO" .
git_track_remotes

if [ "$GIT_FLOW" = "true" ]; then
  $DIR/../gitflow/support/configure.sh
fi

if [ -n "$BRANCH" ] || [ -n "$BRANCH_FILE" ]; then
  if [ -n "$BRANCH_FILE" ]; then
    BRANCH=$(cat "$BRANCH_FILE_SOURCE/$BRANCH_FILE")
  fi

  echo "Checking out branch: $BRANCH"
  git checkout $BRANCH

elif [ "$GIT_FLOW_CHECKOUT_RELEASE" = "true" ]; then
  echo "Checking out git flow release branch"
  source $DIR/../gitflow/support/functions.sh
  gitflow_checkout_release_branch
fi

echo
echo "Git status:"
git status
