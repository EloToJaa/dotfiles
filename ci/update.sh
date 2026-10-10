#!/usr/bin/env bash
set -euo pipefail

kind=$1
name=$2
repo=EloToJaa/dotfiles
base=main
branch="chore/update-$name"

git fetch origin "$base"
git switch -C "$branch" "origin/$base"

if [[ $kind == lock ]]; then
  nix flake update
elif [[ $kind == input ]]; then
  ref_kind=tags
  case "$name" in
  clan-core)
    upstream=https://git.clan.lol/clan/clan-core.git
    # Clan publishes numeric release branches rather than release tags.
    ref_kind=heads
    pattern='^[0-9]+\.[0-9]+$'
    prefix=https://git.clan.lol/clan/clan-core/archive/
    suffix=.tar.gz
    ;;
  hermes-agent)
    upstream=https://github.com/NousResearch/hermes-agent.git
    pattern='^v[0-9]+\.[0-9]+\.[0-9]+$'
    prefix=github:NousResearch/hermes-agent/
    suffix=
    ;;
  bun2nix)
    upstream=https://github.com/nix-community/bun2nix.git
    pattern='^[0-9]+\.[0-9]+\.[0-9]+$'
    prefix=github:nix-community/bun2nix/
    suffix=
    ;;
  yamtrack-src)
    upstream=https://github.com/FuzzyGrim/Yamtrack.git
    pattern='^v[0-9]+\.[0-9]+\.[0-9]+$'
    prefix=github:FuzzyGrim/Yamtrack/
    suffix=
    ;;
  *)
    echo "Unsupported tagged input: $name" >&2
    exit 1
    ;;
  esac
  # Only stable release references, never development branches or prereleases.
  tag=$(git ls-remote --refs "--$ref_kind" "$upstream" | sed "s|.*refs/$ref_kind/||" | grep -E "$pattern" | sort -V | tail -1)
  test -n "$tag"
  url="$prefix$tag$suffix"
  if [[ $name == clan-core ]]; then
    sed -i -E "s|https://git.clan.lol/clan/clan-core/archive/[^\"]+|$url|" flake.nix
  elif [[ $name == hermes-agent ]]; then
    sed -i -E "s|github:NousResearch/hermes-agent/[^\"]+|$url|" flake.nix
  elif [[ $name == bun2nix ]]; then
    sed -i -E "s|github:nix-community/bun2nix/[^\"]+|$url|" flake.nix
  else
    sed -i -E "s|github:FuzzyGrim/Yamtrack/[^\"]+|$url|" flake.nix
    sed -i -E "s|version = \"[^\"]+\";|version = \"${tag#v}\";|; s|/releases/tag/[^\"]+|/releases/tag/$tag|" pkgs/yamtrack/default.nix
  fi
  # Only refresh the selected release input when its reference changes.
  if git diff --quiet; then exit 0; fi
  nix flake update "$name"
else
  case "$name" in
  yazi-*) package_file="pkgs/yazi/${name#yazi-}.nix" ;;
  ai-*) package_file="pkgs/ai/${name#ai-}.nix" ;;
  *) package_file="pkgs/$name/default.nix" ;;
  esac
  # Wrapped builders (e.g. Home Assistant components) report positions in
  # nixpkgs. Always direct nix-update to the repository's package definition.
  update=(nix-update --flake "$name" --override-filename "$package_file")
  case "$name" in
  dreame-vacuum)
    "${update[@]}" --version=stable --version-regex '^v(2\.[0-9]+\.[0-9]+)$'
    ;;
  yazi-* | ai-*)
    # These definitions pin git revisions rather than tagged releases.
    "${update[@]}" --version=branch
    ;;
  streamystats)
    # src wraps the upstream fetcher to inject the vendored Bun lockfile.
    nix-update --flake "$name.updateSource" --override-filename pkgs/streamystats/default.nix
    if git diff --quiet; then exit 0; fi
    nix fmt
    source=$(nix build --no-link --print-out-paths ".#$name.upstreamSrc")
    workdir=$(mktemp -d)
    cp -R "$source/." "$workdir"
    chmod -R u+w "$workdir"
    (cd "$workdir" && bun2nix --lock-file bun.lock --output-file bun.nix)
    cp "$workdir/bun.nix" pkgs/streamystats/bun.nix
    rm -rf "$workdir"
    ;;
  *) "${update[@]}" ;;
  esac
fi

if git diff --quiet; then exit 0; fi
nix fmt
# New source/dependency lockfiles must be visible to the Git flake.
git add -A
if [[ $kind == lock ]]; then
  # No local gate for lock updates: the pull request's checks already build
  # desktop, laptop, server and every package, a superset of anything gated
  # here. Gating instead hid a broken lock inside the effect's own log, where
  # the absence of a PR was the only symptom. Publishing first turns the same
  # breakage into red checks on a PR that can be read and fixed.
  :
elif [[ $kind == package ]]; then
  nix build --no-link ".#$name"
elif [[ $name == yamtrack-src ]]; then
  nix build --no-link .#yamtrack
elif [[ $name == bun2nix ]]; then
  nix build --no-link .#streamystats .#nixosConfigurations.server.config.system.build.toplevel .#nixosConfigurations.desktop.config.system.build.toplevel .#nixosConfigurations.laptop.config.system.build.toplevel
else
  nix build --no-link .#nixosConfigurations.server.config.system.build.toplevel .#nixosConfigurations.desktop.config.system.build.toplevel .#nixosConfigurations.laptop.config.system.build.toplevel
fi

# Avoid rewriting an open PR when the generated tree is unchanged.
push_required=true
if git fetch origin "refs/heads/$branch:refs/remotes/origin/$branch"; then
  if [[ $(git write-tree) == "$(git rev-parse "origin/$branch^{tree}")" ]]; then
    push_required=false
  fi
fi
title="chore($name): update $name"
if [[ $kind == lock ]]; then
  title="chore: update flake.lock"
fi
if [[ $push_required == true ]]; then
  git commit -m "$title"
  git push --force-with-lease origin "HEAD:refs/heads/$branch"
fi
open_prs=$(gh pr list --head "$branch" --state open --repo "$repo" --json number --jq length)
if [[ $open_prs == 0 ]]; then
  gh pr create --repo "$repo" --base "$base" --head "$branch" --title "$title" \
    --body "Automated dependency update from a daily Nixbot effect. Formatting and relevant builds passed before publishing. Host and package checks run on this PR."
fi
