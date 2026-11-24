{
  lib,
  config,
  inputs,
  self,
  ...
}: let
  system = builtins.head config.systems;
  pkgs = inputs.nixpkgs-unstable.legacyPackages.${system};
  effects = inputs.nixbot.lib.effects {inherit pkgs;};
  # Nix 2.35 no longer copies a dirty flake into the store on `nix flake metadata`,
  # so nix-update 1.16.0 fails every version bump while prefetching hashes.
  # Drop once https://github.com/Mic92/nix-update/pull/692 is released.
  nix-update = pkgs.nix-update.overrideAttrs (old: {
    patches =
      (old.patches or [])
      ++ [
        (pkgs.fetchpatch {
          url = "https://github.com/Mic92/nix-update/commit/d545c1fad667e573128cad0db55fdc77134a4d3c.patch";
          includes = ["nix_update/options.py"];
          hash = "sha256-SLxMCM1T5ymd3r5X7Fvz8z/LCUyQcCUvNu1+Y773Tvg=";
        })
      ];
  });
  # Yamtrack's source is a flake input; update it and package metadata together.
  # tmux-smart-splits cannot follow its upstream: smart-splits.nvim v3.0.0 moved
  # every multiplexer backend into a separate repository and deleted the
  # smart-splits.tmux file this plugin loads. mkTmuxPlugin only builds an rtp
  # path and never checks that the file exists, so such a bump would build and
  # pass these checks while leaving tmux navigation dead at runtime.
  # tapo-control cannot move past 7.1.25 yet: 7.2.7 requires pytapo 3.4.26 and
  # imports modules added after the 3.4.19 nixpkgs carries, which its own guard
  # in pkgs/tapo-control refuses to paper over. Updating it daily only produced
  # a failing effect, so hold it until nixpkgs ships a new enough pytapo.
  unmanaged = ["yamtrack" "tmux-smart-splits" "tapo-control"];
  packages = builtins.filter (name: !builtins.elem name unmanaged) (builtins.attrNames self.packages.${system});
  taggedInputs = ["clan-core" "bun2nix" "yamtrack"];
  mkUpdate = kind: name:
    effects.mkEffect {
      name = "update-${kind}-${name}";
      checkout = true;
      lock = "dotfiles-update-${kind}-${name}";
      secretsMap.git.type = "GitToken";
      inputs = with pkgs; [git gh nix coreutils gnugrep gnused gnutar gzip curl jq] ++ [nix-update inputs.bun2nix.packages.${system}.default];
      effectScript = ''
        set -euo pipefail
        export NIX_CONFIG="experimental-features = nix-command flakes"
        export GH_TOKEN="$(jq -er '.git.data.token' "$HERCULES_CI_SECRETS_JSON")"
        export GITHUB_TOKEN="$GH_TOKEN"
        git config --global user.name "dotfiles-bot"
        git config --global user.email "dotfiles-bot@users.noreply.github.com"
        git config --global safe.directory "$NIXBOT_EFFECT_CHECKOUT"
        cd "$NIXBOT_EFFECT_CHECKOUT"
        bash ${./update.sh} ${lib.escapeShellArgs [kind name]}
      '';
    };
  # Removes an update branch once its PR merges, so the next run starts a fresh
  # branch and PR. The head check skips a branch that a later run re-pushed.
  deleteUpdateBranch = effects.mkEffect {
    name = "delete-update-branch";
    when = {
      branches = ["main"];
      labels = ["auto-merge"];
    };
    secretsMap.git.type = "GitToken";
    inputs = with pkgs; [gh jq];
    effectScript = ''
      set -euo pipefail
      export GH_TOKEN="$(jq -er '.git.data.token' "$HERCULES_CI_SECRETS_JSON")"
      pr="$NIXBOT_EVENT_JSON"
      if [[ $(jq -r '.pullRequest.merged' "$pr") != true || $(jq -r '.pullRequest.isFork' "$pr") != false ]]; then exit 0; fi
      branch=$(jq -er '.pullRequest.headRef' "$pr")
      if [[ $branch != chore/update-* ]]; then exit 0; fi
      head=$(gh api "repos/EloToJaa/dotfiles/git/ref/heads/$branch" --jq .object.sha 2>/dev/null) || exit 0
      if [[ $head != "$(jq -er '.pullRequest.headRev' "$pr")" ]]; then exit 0; fi
      gh api -X DELETE "repos/EloToJaa/dotfiles/git/refs/heads/$branch"
    '';
  };
in {
  perSystem = {system, ...}: {
    checks = lib.genAttrs ["server" "desktop" "laptop" "worker" "hbox" "wsl"] (host: self.nixosConfigurations.${host}.config.system.build.toplevel);
  };
  flake.herculesCI = {...}: {
    ciSystems = [system];
    onEvent.pull_request_closed.delete-update-branch = deleteUpdateBranch;
    onSchedule.flake-lock-updates = {
      when = {
        hour = 4;
        minute = 0;
      };
      outputs.effects.update-flake-lock = mkUpdate "lock" "flake-lock";
    };
    onSchedule.package-updates = {
      when = {
        hour = 5;
        minute = 0;
      };
      outputs.effects =
        lib.genAttrs packages (mkUpdate "package")
        // lib.genAttrs taggedInputs (mkUpdate "input");
    };
  };
}
