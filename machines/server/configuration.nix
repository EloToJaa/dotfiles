{config, ...}: let
  inherit (config.settings) username;
in {
  _module.args.host = "server";
  imports = [
    ./config.nix
    {
      home-manager.users.${username}.imports = [
        ./home.nix
      ];
    }
  ];
}
