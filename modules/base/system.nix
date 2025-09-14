{
  pkgs,
  inputs,
  variables,
  outputs,
  ...
}: {
  imports = [inputs.nix-gaming.nixosModules.pipewireLowLatency];
  nix = {
    settings = {
      auto-optimise-store = true;
      experimental-features = ["nix-command" "flakes"];
      substituters = [
        "https://nix-community.cachix.org"
        "https://nix-gaming.cachix.org"
        "https://hyprland.cachix.org"
        "https://yazi.cachix.org"
      ];
      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4="
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
        "yazi.cachix.org-1:Dcdz63NZKfvUCbDGngQDAZq6kOroIrFoyO064uvLh8k="
      ];
      trusted-users = [variables.username];
    };
  };

  environment.systemPackages = with pkgs.unstable; [
    wget
  ];

  time.timeZone = variables.timezone;
  i18n.defaultLocale = variables.locale;
  system.stateVersion = variables.stateVersion;

  nixpkgs = {
    overlays = [
      inputs.nur.overlays.default
      outputs.overlays.unstable-packages
      outputs.overlays.additions
      outputs.overlays.modifications
    ];
    config = {
      allowUnfree = true;
      allowInsecurePredicate = _: true;
    };
  };
}
