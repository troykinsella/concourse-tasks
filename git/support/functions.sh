
git_branch_exists() {
  local name=$1
  git branch -a | grep "$name" > /dev/null
}

git_current_branch() {
  git rev-parse --abbrev-ref HEAD
}

git_tag_exists() {
  local name=$1
  test "$(git tag -l | grep "$name")" = "$name"
}

git_ensure_branch() {
  local name=$1
  test "$(git_current_branch)" = "$name" || { echo "$name branch must be checked out" >&2; exit 1; }
}

git_check_branch_current() {
  local branch_a=$1
  local branch_b=$2

  git fetch origin $branch_a
  git fetch origin $branch_b
  local diff=$(git rev-list --left-right --count $branch_a...$branch_b | awk '{print $2}')

  test "$diff" -eq 0
}

git_track_remotes() {
  for i in $(git branch -r | grep -v "HEAD"); do
    git branch --track ${i#*/} $i || true
  done
}
