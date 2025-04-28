{...}: {
  home-manager.users.sonarr.imports = [
    ./service.nix
  ];

  services.sonarr = {
    enable = true;
    user = "sonarr";
    group = "sonarr";
  };

  users.users.sonarr = {
    isNormalUser = true;
    description = "Sonarr";
    group = "sonarr";
  };
}
