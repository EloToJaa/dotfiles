{
  config,
  inputs,
  ...
}: let
  inherit (config.settings) username;
in {
  _module.args.host = "server";
  modules.shared = {
    cpu.vendor = "intel";
    graphics = {
      vendor = "intel";
      earlyBoot = false;
    };
  };
  imports = [
    inputs.srvos.nixosModules.server
    ./config.nix
    ../../homeModules/vars.nix
    {
      home-manager.users.${username}.imports = [
        ../../homeModules/server.nix
      ];
    }
  ];
}
