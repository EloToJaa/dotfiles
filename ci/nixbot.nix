{
  lib,
  inputs,
  self,
  ...
}: let
  system = "x86_64-linux";
  pkgs = inputs.nixpkgs-unstable.legacyPackages.${system};
  effects = inputs.nixbot.lib.effects {inherit pkgs;};
  # Yamtrack's source is a flake input; update it and package metadata together.
  packages = builtins.filter (name: name != "yamtrack") (builtins.attrNames self.packages.${system});
  taggedInputs = ["clan-core" "hermes-agent" "bun2nix" "yamtrack-src"];
  mkUpdate = kind: name:
    effects.mkEffect {
      name = "update-${kind}-${name}";
      checkout = true;
      lock = "dotfiles-update-${kind}-${name}";
      secretsMap.git.type = "GitToken";
      inputs = with pkgs; [git gh nix nix-update coreutils gnugrep gnused gnutar gzip] ++ [inputs.bun2nix.packages.${system}.default];
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
in {
  perSystem = {system, ...}: {
    checks = lib.genAttrs ["server" "desktop" "laptop"] (host: self.nixosConfigurations.${host}.config.system.build.toplevel);
  };
  flake.herculesCI = {...}: {
    ciSystems = [system];
    onSchedule.flake-lock-updates = {
      when = {
        hour = 2;
        minute = 0;
      };
      outputs.effects.update-flake-lock = mkUpdate "lock" "flake-lock";
    };
    onSchedule.package-updates = {
      when = {
        hour = 3;
        minute = 0;
      };
      outputs.effects =
        lib.genAttrs packages (mkUpdate "package")
        // lib.genAttrs taggedInputs (mkUpdate "input");
    };
  };
}
