{
  lib,
  pkgs,
  effects,
}: let
  pytapo_version = pkgs.home-assistant.python3Packages.pytapo.version;

  nix_update = {
    reason = "Nix 2.35 no longer copies a dirty flake into the store on `nix flake metadata`, so nix-update 1.16.0 fails every version bump while prefetching hashes.";
    removeWhen = "https://github.com/Mic92/nix-update/pull/692 is merged and nixpkgs ships a nix-update release containing it; the patch then no longer applies and the build fails.";
    check = ''test "$(gh api repos/Mic92/nix-update/pulls/692 --jq .merged)" = true'';
  };

  unmanaged = {
    yamtrack = {
      reason = "Its source is a flake input, so the input update bumps the source and package metadata together.";
      removeWhen = "Never, while its source stays a flake input.";
    };
    tmux-smart-splits = {
      reason = "smart-splits.nvim v3.0.0 moved every multiplexer backend into a separate repository and deleted the smart-splits.tmux file this plugin loads. A bump would still build, since mkTmuxPlugin never checks that the file exists, but leave tmux navigation dead at runtime.";
      removeWhen = "The package follows the repository that now hosts the tmux backend.";
    };
    tapo-control = {
      reason = "7.2.7 requires pytapo 3.4.26 and imports modules missing from older pytapo, which the guard in pkgs/tapo-control refuses to paper over. Updating it daily only produced a failing effect.";
      removeWhen = "nixpkgs ships pytapo 3.4.26 or newer.";
      check = lib.boolToString (lib.versionAtLeast pytapo_version "3.4.26");
    };
  };

  checked = lib.filterAttrs (_: workaround: workaround ? check) ({nix-update = nix_update;} // unmanaged);

  checkEffect = effects.mkEffect {
    name = "check-workarounds";
    secretsMap.git.type = "GitToken";
    inputs = with pkgs; [gh jq];
    effectScript = ''
      set -euo pipefail
      export GH_TOKEN="$(jq -er '.git.data.token' "$HERCULES_CI_SECRETS_JSON")"
      removable=()
      ${lib.concatStrings (lib.mapAttrsToList (name: workaround: ''
          if ${workaround.check}; then
            removable+=(${lib.escapeShellArg "${name}: ${workaround.removeWhen}"})
          fi
        '')
        checked)}
      if [[ ''${#removable[@]} -eq 0 ]]; then exit 0; fi
      echo "Workarounds in ci/workarounds.nix that can be removed:" >&2
      printf ' - %s\n' "''${removable[@]}" >&2
      exit 1
    '';
  };
in {
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
  unmanaged = builtins.attrNames unmanaged;
  inherit checkEffect;
}
