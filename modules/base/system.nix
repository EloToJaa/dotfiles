{
  pkgs,
  inputs,
  variables,
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
      ];
      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4="
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
      ];
    };
  };
  nixpkgs.overlays = [
    inputs.nur.overlays.default
  ];

  environment.systemPackages = with pkgs; [
    wget
    git
  ];

  time.timeZone = "${variables.timezone}";
  i18n.defaultLocale = "${variables.locale}";
  nixpkgs.config.allowUnfree = true;
  system.stateVersion = "${variables.stateVersion}";
}
