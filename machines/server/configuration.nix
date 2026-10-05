{
  config,
  inputs,
  ...
}: let
  inherit (config.settings) username;
in {
  _module.args.host = "server";
  modules.shared = {
    btrfs = {
      scrub.enable = true;
      snapshots = {
        enable = true;
        subvolumes = {
          home = "/home";
          opt = "/opt";
          var-lib = "/var/lib";
        };
      };
    };
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
