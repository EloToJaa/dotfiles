{variables, ...}: {
  home-manager.users.${variables.username}.imports = [
    ./packages.nix
  ];

  imports = [
    ./steam.nix
  ];
}
