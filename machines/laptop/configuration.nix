{flake, ...}: {
  imports = [
    # ../../settings.nix
    flake.homeModules.default
    ./config.nix
    {
      home-manager.users.elotoja.imports = [
        ./home.nix
      ];
    }
  ];
}
