{config, ...}: let
  inherit (config.settings) username;
in {
  _module.args.host = "laptop";
  imports = [
    ./config.nix
    {
      home-manager.users.${username}.imports = [
        ./home.nix
      ];
    }
  ];
}
