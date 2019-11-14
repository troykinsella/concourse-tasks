#!/usr/bin/env bash

set -e

SOURCE_IN="$PWD/$1"
MESSAGE_DIR="$PWD/$2"

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" > /dev/null && pwd)"
source $DIR/../git/support/functions.sh
source $DIR/support/functions.sh
$DIR/../git/support/configure.sh

cd $SOURCE_IN

message_opt() {
  if [ -n "$MESSAGE" ]; then
    echo "-m '$MESSAGE'"
  elif [ -n "$MESSAGE_FILE" ]; then
    echo "-m '$(cat "$MESSAGE_DIR/$MESSAGE_FILE")'"
  fi
}

if [ "$DRY_RUN" = "true" ]; then
  echo "Dry run: Skipping release finish"
else
  export GIT_MERGE_AUTOEDIT=no
  git flow release finish --showcommands -p -D $(message_opt)
  unset GIT_MERGE_AUTOEDIT
fi
