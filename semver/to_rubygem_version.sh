#!/usr/bin/env bash

set -e

VERSION_DIR=$PWD/$1
OUT=$PWD/$2

VERSION=$(cat ${VERSION_DIR}/number)

echo "Semver: ${VERSION}"

FINAL_PART=$(echo ${VERSION} | awk -F- '{print $1}')
PRE_PART=$(echo ${VERSION} | sed "s/^${FINAL_PART}//" | sed "s/^-//")
if [ -z "${PRE_PART}" ]; then
  RG_VERSION="${VERSION}"
else
  RG_PRE_PART=$(echo ${PRE_PART} | sed -E 's/[_\-](.)/\U\1/g' | tr -d '.')
  RG_VERSION="${FINAL_PART}.${RG_PRE_PART}"
fi

echo "RubyGems: ${RG_VERSION}"

echo ${RG_VERSION} > ${OUT}/number
