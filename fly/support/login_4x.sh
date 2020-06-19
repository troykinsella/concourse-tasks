#!/usr/bin/env bash

set -ex

# Variables

BASE_URL=$1
USERNAME=$2
FLY_TARGET=$3
TEAM=${4:-main}
PASSWORD=$(cat)
COOKIE_FILE=$(mktemp /tmp/fly_login_cookie.XXXXXX)

# Functions

usage() {
  echo "usage: echo <password> | $0 <base_url> <username> <fly_target> [team]"
}

prefix_base_url() {
  local url_or_path=$1
  if [[ $url_or_path == $BASE_URL* ]]; then
    echo $url_or_path
  else
    echo "${BASE_URL}${url_or_path}"
  fi
}

init_login() {
  local login_url="${BASE_URL}/sky/login"

  # Call the login URL, extracting the Location header
  local auth2="$(curl --fail -b $COOKIE_FILE -c $COOKIE_FILE -s -o /dev/null -L "$login_url" -D - | \
    grep -i "Location:" | grep "/sky/issuer/auth" | cut -d ' ' -f 2 | tr -d '\r' | tr -d '\n')"

  # Check for goodness
  test "$?" = "0" || { echo "Failed to GET $login_url"; exit 1; }
  test -z "${auth2}" && { echo "Unable to extract Location header from login response" >&2; exit 1; }

  prefix_base_url $auth2
}

cookie_oauth_token() {
  cat $COOKIE_FILE | grep 'skymarshal_auth' | grep -i -o 'Bearer .*$' | tr -d '"'
}

scrape_auth_local() {
  local auth_local=$(sed 's|.*\(/sky/issuer/auth/local[^\"]*\).*|\1|')
  test -z "$auth_local" && { echo "Unable to extract local auth URL" >&2; exit 1; }

  prefix_base_url $auth_local
}

post_credentials() {
  local url=$1
  curl --fail -s -b $COOKIE_FILE -c $COOKIE_FILE -L --data-urlencode "login=${USERNAME}" \
    --data-urlencode "password=${PASSWORD}" "${url}"

  # Check for goodness
  test "$?" = "0" || { echo "Failed to POST $url"; exit 1; }
}

obtain_oauth_token() {
  local auth2=$1
  local auth2_out=$(post_credentials $auth2)

  local token=$(cookie_oauth_token)
  if [ -z "$token" ]; then
    # There's no token in the cookie, so assume we posted to an intermediary
    # auth method selection page. From this page, scrape the local auth method
    # URL and post to it.
    auth2=$(echo $auth2_out | scrape_auth_local)
    auth2_out=$(post_credentials $auth2)
    token=$(cookie_oauth_token)
  fi

  test -z "$token" && { echo "Failed to login" >&2; exit 1; }

  echo $token
}

# Main

test -z "$BASE_URL" && usage
test -z "$USERNAME" && usage
test -z "$PASSWORD" && usage

AUTH2=$(init_login)
TOKEN=$(obtain_oauth_token $AUTH2)

echo $TOKEN | fly -t $FLY_TARGET login -c $BASE_URL -n $TEAM

rm $COOKIE_FILE
