{
  config,
  inputs,
  ...
}: let
  inherit (config.settings) username;
in {
  _module.args.host = "server";
  imports = [
    inputs.srvos.nixosModules.server
    ./config.nix
    {
      home-manager.users.${username}.imports = [
        ./home.nix
      ];
    }
  ];
}
