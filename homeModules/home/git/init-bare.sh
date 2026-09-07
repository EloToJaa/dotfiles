#!/usr/bin/env bash
set -euo pipefail

if (($# > 1)); then
  echo "Usage: git init-bare [directory]" >&2
  exit 1
fi

# Git shell aliases run from the repository root; restore the caller's directory.
cd "${GIT_PREFIX:-.}"
# Avoid carrying the invoking worktree's Git paths into the new repository.
unset GIT_DIR GIT_WORK_TREE GIT_COMMON_DIR GIT_INDEX_FILE
directory=${1:-.}
mkdir -p -- "$directory"
cd -- "$directory"

shopt -s nullglob dotglob
entries=(*)
if ((${#entries[@]})); then
  echo "git init-bare: directory must be empty: $directory" >&2
  exit 1
fi

git init --bare --initial-branch=main .
echo "gitdir: ./" >.git
# Seed main before workmux tries to use it as a base branch.
initial_commit=$(git commit-tree "$(git mktree </dev/null)" -m "feat(proj): initial commit")
git update-ref refs/heads/main "$initial_commit"
workmux add main
