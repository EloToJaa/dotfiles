{...}: {
  home-manager.users.sonarr.imports = [
    ./service.nix
  ];

  users.users.sonarr = {
    isNormalUser = true;
    description = "Sonarr";
    group = "sonarr";
  };
}
