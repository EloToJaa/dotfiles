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
  workarounds = import ./workarounds.nix {inherit lib pkgs effects;};
  inherit (workarounds) nix-update unmanaged;
  packages = builtins.filter (name: !builtins.elem name unmanaged) (builtins.attrNames self.packages.${system});
  taggedInputs = ["clan-core" "bun2nix" "unifi-mcp" "yamtrack" "agent-browser-skills" "mattpocock-skills" "workmux-skills"];
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
    onSchedule.workaround-checks = {
      when = {
        hour = 6;
        minute = 0;
      };
      outputs.effects.check-workarounds = workarounds.checkEffect;
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
