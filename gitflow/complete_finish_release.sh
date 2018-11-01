#!/bin/sh

set -ex

SOURCE_IN=$PWD/$1

DIR=$(dirname $0)
source $DIR/../git/support/functions.sh
source $DIR/support/functions.sh

cd $SOURCE_IN

VERSION=$(gitflow_require_release_version)

if [ "$DRY_RUN" = "true" ]; then
  echo "Dry run: Skipping release finish"
else
  export GIT_MERGE_AUTOEDIT=no
  git flow release finish --showcommands -p -D -m "chore(release): Release $VERSION"
  unset GIT_MERGE_AUTOEDIT
fi
