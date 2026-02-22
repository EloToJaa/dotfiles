{
  networking.hostName = "laptop";
  _module.args.host = "laptop";
  imports = [
    ./config.nix
    {
      home-manager.users.elotoja.imports = [
        ./home.nix
      ];
    }
  ];
}
