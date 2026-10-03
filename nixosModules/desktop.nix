{lib, ...}: {
  networking = {
    useDHCP = lib.mkForce true;
  };

  powerManagement.cpuFreqGovernor = "performance";

  imports = [
    ./default.nix
  ];

  boot.loader.limine.extraEntries = ''
    /Windows 10
      protocol: chainload
      path: boot():///EFI/Microsoft/Boot/bootmgfw.efi
  '';

  modules = {
    base = {
      enable = true;
      bootloader.enable = true;
      tailscale.enable = true;
      ssh.enable = true;
      sudo.enable = true;
      plymouth.enable = true;
    };
    shared = {
      btrfs = {
        scrub.enable = true;
        snapshots = {
          enable = true;
          subvolumes.home = "/home";
        };
      };
      btop.enable = true;
      catppuccin.enable = true;
      containers.enable = true;
      index.enable = true;
      nfs.enable = true;
      nh.enable = true;
    };
    core = {
      enable = true;
      adb.enable = false;
      audio.enable = true;
      bluetooth.enable = true;
      camera.enable = true;
      gnome.enable = true;
      mullvad.enable = true;
      printing.enable = false;
      security.enable = true;
      steam.enable = true;
      virtualization.enable = true;
      wayland = {
        enable = true;
        hyprland.enable = false;
        niri.enable = true;
      };
    };
    homelab.groups.enable = true;
  };
}
