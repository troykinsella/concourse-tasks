#!/bin/bash

set -e

ROOT=$PWD/$1
OUT=$PWD/$2
DOCKERFILE=${DOCKERFILE:-Dockerfile}

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" > /dev/null && pwd)"
source $DIR/support/init.sh

target_option() {
  if [ -n "$TARGET" ]; then
    echo "--target $TARGET"
  fi
}

start_docker

if [ -n "$REGISTRY" ]; then
  test -z "$USERNAME" && { echo "USERNAME required when REGISTRY supplied" >&2; exit 1; }
  test -z "$PASSWORD" && { echo "PASSWORD required when REGISTRY supplied" >&2; exit 1; }

  docker_log_in "$USERNAME" "$PASSWORD" "$REGISTRY"
fi

expanded_build_args=()
build_arg_keys=($(echo "$BUILD_ARGS" | jq -r 'keys | join(" ")'))
if [ "${#build_arg_keys[@]}" -gt 0 ]; then
  for key in "${build_arg_keys[@]}"; do
    value=$(echo "$BUILD_ARGS" | jq -r --arg "k" "$key" '.[$k]')
    expanded_build_args+=("--build-arg")
    expanded_build_args+=("${key}=${value}")
  done
fi

expanded_labels=()
label_keys=($(echo "$LABELS" | jq -r 'keys | join(" ")'))
if [ "${#label_keys[@]}" -gt 0 ]; then
  for key in "${label_keys[@]}"; do
    value=$(echo "$labels" | jq -r --arg "k" "$key" '.[$k]')
    expanded_labels+=("--label")
    expanded_labels+=("${key}=${value}")
  done
fi

cd $ROOT
docker build ${target_option} ${expanded_build_args[@]} ${expanded_labels[@]} -f $DOCKERFILE .

if [ "$SAVE" = "true" ]; then
  IMAGE_ID=$(docker images | awk '{print $1}' | awk 'NR==2')

  COMPRESS_FILTER=cat
  IMAGE_EXT=tar
  if [ "$COMPRESS_SAVE" = "true" ]; then
    COMPRESS_FILTER=gzip
    IMAGE_EXT=tar.gz
  fi

  IMAGE_FILE="$OUT/image.$IMAGE_EXT"
  echo "Saving image to $IMAGE_FILE"

  docker save $IMAGE_ID | $COMPRESS_FILTER > $IMAGE_FILE
fi
