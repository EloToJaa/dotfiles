#!/usr/bin/env bash
set -e

# https://morgan.cugerone.com/blog/workarounds-to-git-worktree-using-bare-repository-and-cannot-fetch-remote-branches/

url=$1
basename=${url##*/}
name=${2:-${basename%.*}}

git clone --bare "$url" "$name"

cd "$name"
echo "gitdir: ./" >.git

# Explicitly sets the remote origin fetch so we can fetch remote branches
git config remote.origin.fetch "+refs/heads/*:refs/remotes/origin/*"

# Gets all branches from origin
git fetch origin
