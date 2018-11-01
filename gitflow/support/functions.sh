
gitflow_release_branch_name() {
  echo "release/${VERSION_PREFIX}${VERSION}"
}

gitflow_develop_current_with_master() {
  git_check_branch_current develop master
}

gitflow_find_release_version() {
  git branch -a | fgrep 'release/' | sort | tail -1 | awk -F '/' '{print $NF}'
}

