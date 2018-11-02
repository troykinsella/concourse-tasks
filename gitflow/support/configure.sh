
gf_set() {
  local key=$1
  local value=$2
  git flow config set --local $key $value
}

git flow init -fd

gf_set master     ${GIT_FLOW_MASTER_BRANCH:-master}
gf_set develop    ${GIT_FLOW_DEVELOP_BRANCH:-develop}
gf_set feature    ${GIT_FLOW_FEATURE_PREFIX:-feature/}
gf_set bugfix     ${GIT_FLOW_BUGFIX_PREFIX:-bugfix/}
gf_set release    ${GIT_FLOW_RELEASE_PREFIX:-release/}
gf_set hotfix     ${GIT_FLOW_HOTFIX_PREFIX:-hotfix/}
gf_set support    ${GIT_FLOW_SUPPORT_PREFIX:-support/}
gf_set versiontag ${VERSION_PREFIX:-""}
