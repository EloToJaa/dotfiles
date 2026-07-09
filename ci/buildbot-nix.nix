{
  inputs,
  lib,
  ...
}: let
  system = "x86_64-linux";
  pkgs = import inputs.nixpkgs {inherit system;};

  packageNames = [
    "cleanuparr"
    "energa-my-meter"
    "jellystat"
    "musicseerr"
  ];
  packageArgs = lib.escapeShellArgs packageNames;

  mkEffect = {
    name,
    effectScript,
  }:
    pkgs.stdenvNoCC.mkDerivation {
      inherit name effectScript;
      isEffect = true;
      secretsMap = builtins.toJSON {};
      nativeBuildInputs = with pkgs; [
        bash
        cacert
        coreutils
        gh
        git
        gnugrep
        jq
        nix
        nix-update
      ];
      phases = [
        "initPhase"
        "effectPhase"
      ];
      initPhase = ''
        exec </dev/null
        export HOME=/build/home
        mkdir -p "$HOME"
      '';
      effectPhase = ''eval "$effectScript"'';
    };
in {
  flake.herculesCI = {primaryRepo, ...}: let
    baseBranch = primaryRepo.branch or "main";
    repoUrl = primaryRepo.remoteHttpUrl or "https://github.com/EloToJaa/dotfiles";
  in {
    onSchedule.package-updates = {
      when = {
        hour = 3;
        minute = 0;
      };

      outputs.effects.update-packages = mkEffect {
        name = "update-custom-nix-packages";
        effectScript = ''
          set -euo pipefail

          token="$(${pkgs.jq}/bin/jq -er '.github.data.token' "$HERCULES_CI_SECRETS_JSON")"
          repo_url=${builtins.toJSON repoUrl}
          base_branch=${builtins.toJSON baseBranch}

          case "$repo_url" in
            git@github.com:*)
              repo_path="''${repo_url#git@github.com:}"
              repo_path="''${repo_path%.git}"
              ;;
            https://github.com/*)
              repo_path="''${repo_url#https://github.com/}"
              repo_path="''${repo_path%.git}"
              ;;
            *)
              echo "Unsupported GitHub repository URL: $repo_url" >&2
              exit 1
              ;;
          esac

          workdir="$(mktemp -d)"
          trap 'rm -rf "$workdir"' EXIT

          export GH_TOKEN="$token"
          export GIT_AUTHOR_NAME="buildbot-nix"
          export GIT_AUTHOR_EMAIL="buildbot-nix@users.noreply.github.com"
          export GIT_COMMITTER_NAME="$GIT_AUTHOR_NAME"
          export GIT_COMMITTER_EMAIL="$GIT_AUTHOR_EMAIL"

          clone_url="https://x-access-token:$token@github.com/$repo_path.git"
          git clone --depth 1 --branch "$base_branch" "$clone_url" "$workdir/repo"
          cd "$workdir/repo"

          base_rev="$(git rev-parse --short HEAD)"
          update_branch="buildbot-nix/update-custom-pkgs-$base_rev"
          git switch -c "$update_branch"

          for package in ${packageArgs}; do
            nix-update --flake "$package"
          done

          nix fmt

          if git diff --quiet; then
            echo "No package updates found."
            exit 0
          fi

          for package in ${packageArgs}; do
            nix build ".#$package"
          done

          git add -A
          git commit -m "chore: update custom nix packages"
          git push --force-with-lease origin "$update_branch"

          body="Automated custom package update from buildbot-nix scheduled effects."
          if gh pr view "$update_branch" --repo "$repo_path" >/dev/null 2>&1; then
            gh pr edit "$update_branch" \
              --repo "$repo_path" \
              --title "chore: update custom nix packages" \
              --body "$body"
          else
            gh pr create \
              --repo "$repo_path" \
              --base "$base_branch" \
              --head "$update_branch" \
              --title "chore: update custom nix packages" \
              --body "$body" \
              --label dependencies \
              --label automated
          fi
        '';
      };
    };
  };
}
