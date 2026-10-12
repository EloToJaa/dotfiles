{
  pkgs,
  inputs,
  outputs,
  lib,
  config,
  ...
}: let
  inherit (config.settings) username timezone locale stateVersion;
  cfg = config.modules.base;
  # the machine serving the cache doesn't need to substitute from itself
  useHarmonia = !config.modules.homelab.harmonia.enable;
in {
  config = lib.mkIf cfg.enable {
    nixpkgs.flake.source = lib.mkForce inputs.nixpkgs-unstable.outPath;
    nix = {
      settings = {
        auto-optimise-store = true;
        experimental-features = ["nix-command" "flakes"];
        substituters =
          [
            "https://nix-community.cachix.org"
            "https://nix-gaming.cachix.org"
            "https://hyprland.cachix.org"
            "https://yazi.cachix.org"
            "https://vicinae.cachix.org"
            "https://cache.numtide.com"
            "https://niri-nix.cachix.org"
          ]
          ++ lib.optional useHarmonia "https://cache.elotoja.com";
        trusted-public-keys =
          [
            "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
            "nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4="
            "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
            "yazi.cachix.org-1:Dcdz63NZKfvUCbDGngQDAZq6kOroIrFoyO064uvLh8k="
            "vicinae.cachix.org-1:1kDrfienkGHPYbkpNj1mWTr7Fm1+zcenzgTizIcI3oc="
            "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
            "niri-nix.cachix.org-1:SvFtqpDcf7Sm1SMJdby1/+Y+6f3Yt3/3PMcSTKPJNJ0="
          ]
          # public half of worker's harmonia-signing-key clan var
          ++ lib.optional useHarmonia "cache.elotoja.com-1:P4PJb6FBr98paRwCpyUVY8ce4H9MsGbwtfMG8t5Ys3k=";
        trusted-users = [username];
      };
    };

    environment.systemPackages = with pkgs.unstable; [
      wget
      neovim
    ];

    time.timeZone = timezone;
    i18n.defaultLocale = locale;
    system.stateVersion = stateVersion;

    nixpkgs = {
      overlays = [
        inputs.nur.overlays.default
        outputs.overlays.bun2nix
        outputs.overlays.helium
        outputs.overlays.unstablePackages
        outputs.overlays.modifiedPackages
        outputs.overlays.localPackages
      ];
      config = {
        allowUnfree = true;
      };
    };
  };
}
