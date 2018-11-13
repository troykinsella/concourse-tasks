#!/usr/bin/env bash

set -e

VOLUME=$PWD/$1
RESULT=$PWD/$2

test -z "$COMMAND" && { echo "Must supply COMMAND parameter" >&2; exit 1; }

test -n "$DIR" && cd $DIR

cp . -r $RESULT
cd $RESULT

if [ "$ECHO" = "true" ]; then
  set -x
fi

$COMMAND
