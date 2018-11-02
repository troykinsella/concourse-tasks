#!/usr/bin/env bash

set -e

IN=$PWD/$1
OUT=$PWD/$2

test -z "$MESSAGE" && { echo "Must supply MESSAGE param" >&2; exit 1; }

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" > /dev/null && pwd)"
$DIR/support/configure.sh

cp -r $IN/. $OUT
cd $OUT

git add ${GIT_ADD_LIST:-"--all"}

(
  set -x
  git status
  git commit -m "$MESSAGE"
) || true
