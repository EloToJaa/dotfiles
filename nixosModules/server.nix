{lib, ...}: {
  networking = {
    useDHCP = lib.mkForce true;
  };

  settings.isServer = true;

  powerManagement.cpuFreqGovernor = "performance";
  imports = [
    ./default.nix
  ];

  modules = {
    base = {
      enable = true;
      bootloader.enable = true;
      initrd.enable = false;
      tailscale.enable = true;
      ssh.enable = true;
      sudo.enable = true;
    };
    shared = {
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
      btop.enable = true;
      catppuccin.enable = true;
      containers.enable = true;
      index.enable = true;
      nfs.enable = true;
      nh.enable = true;
    };
    homelab = {
      enable = true;
      groups.enable = true;
    };
  };
}
