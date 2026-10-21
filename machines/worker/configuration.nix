{
  config,
  inputs,
  ...
}: let
  inherit (config.settings) username;
in {
  _module.args.host = "worker";
  srvos.boot.consoles = ["tty0"]; # no serial port; srvos default spawns a failing serial-getty@ttyS0
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
    ./disko.nix
    ../../homeModules/vars.nix
    {
      home-manager.users.${username}.imports = [
        ./home.nix
      ];
    }
  ];
}
