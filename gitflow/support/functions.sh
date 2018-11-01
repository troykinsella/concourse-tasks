
gitflow_release_branch_name() {
  echo "release/${VERSION}"
}

gitflow_develop_current_with_master() {
  git_check_branch_current develop master
}

gitflow_find_release_version() {
  git branch -a | fgrep 'release/' | sort | tail -1 | awk -F '/' '{print $NF}'
}

gitflow_require_release_version() {
  local version=$(gitflow_find_release_version)
  test -z "$version" && { echo "Release branch not found" >&2; exit 1; }
}

gitflow_checkout_release_branch() {
  local version=$(gitflow_find_release_version)
  git checkout feature/${version}
}
