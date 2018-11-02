#!/usr/bin/env bash

set -ex

VERSION_DIR=$PWD/$1
SOURCE_IN=$PWD/$2

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" > /dev/null && pwd)"
source $DIR/../git/support/functions.sh
source $DIR/support/functions.sh

cd $SOURCE_IN

VERSION=$(cat $VERSION_DIR/number)

git_ensure_branch $(gitflow_release_branch_name)

if [ "$DRY_RUN" = "true" ]; then
  echo "Dry run: Skipping release publish"
else
  git flow release publish --showcommands $VERSION
fi

echo "Published $(gitflow_release_branch_name)"
