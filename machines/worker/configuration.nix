{config, ...}: let
  inherit (config.settings) username;
in {
  _module.args.host = "worker";
  modules.shared = {
    cpu.vendor = "intel";
    graphics = {
      vendor = "intel";
      earlyBoot = false;
    };
  };

  # The kernel command line only changes on reboot, so a worker that booted
  # before srvos.boot.consoles dropped ttyS0 keeps getting a generated
  # serial-getty@ttyS0 that fails in a loop. Masking it fixes that without one.
  systemd.services."serial-getty@ttyS0".enable = false;

  imports = [
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
