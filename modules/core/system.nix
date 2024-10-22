{ self, pkgs, lib, inputs, variables, ...}: 
{
  imports = [ inputs.nix-gaming.nixosModules.pipewireLowLatency ];
  nix = {
    settings = {
      auto-optimise-store = true;
      experimental-features = [ "nix-command" "flakes" ];
      substituters = [ "https://nix-gaming.cachix.org" ];
      trusted-public-keys = [ "nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4=" ];
    };
  };
  nixpkgs.overlays = [
    inputs.nur.overlay
  ];

  environment.systemPackages = with pkgs; [
    wget
    git
    # bzip2
  ];

  time.timeZone = "${variables.timezone}";
  i18n.defaultLocale = "${variables.locale}";
  nixpkgs.config.allowUnfree = true;
  system.stateVersion = "${variables.stateVersion}";
}
