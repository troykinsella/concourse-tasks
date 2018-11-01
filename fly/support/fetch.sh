#!/usr/bin/env bash

set -e

usage() {
  echo "usage: $0 [options] <base_url> [fly_path]"
}

if [ "$1" = "-i" ] || [ "$1" == "--insecure" ]; then
  INSECURE_OPT=--insecure
  shift
fi

BASE_URL=$1
FLY=${2:-/usr/local/bin/fly}

test -z "$BASE_URL" && usage

curl -SsL $INSECURE_OPT -o $FLY "${BASE_URL}/api/v1/cli?arch=amd64&platform=linux"
chmod +x $FLY
