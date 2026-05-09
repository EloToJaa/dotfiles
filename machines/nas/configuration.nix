{config, ...}: let
  inherit (config.settings) username;
in {
  _module.args.host = "nas";
  imports = [
    ./config.nix
    ../../homeModules/vars.nix
    {
      home-manager.users.${username}.imports = [
        ./home.nix
      ];
    }
  ];
}
