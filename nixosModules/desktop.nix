{lib, ...}: {
  networking = {
    useDHCP = lib.mkForce true;
  };

  powerManagement.cpuFreqGovernor = "performance";

  imports = [
    ./default.nix
  ];

  boot.loader.limine.extraEntries = ''
    /Windows 11
      protocol: efi
      path: boot():/EFI/Microsoft/Boot/bootmgfw.efi
  '';

  modules = {
    base = {
      enable = lib.mkDefault true;
      nix-ld.enable = lib.mkDefault true;
      smartd.enable = lib.mkDefault true;
      bootloader.enable = lib.mkDefault true;
      initrd.enable = lib.mkDefault true;
      tailscale.enable = lib.mkDefault true;
      ssh.enable = lib.mkDefault true;
      sudo.enable = lib.mkDefault true;
    };
    shared = {
      btop.enable = lib.mkDefault true;
      catppuccin.enable = lib.mkDefault true;
      containers.enable = lib.mkDefault true;
      index.enable = lib.mkDefault true;
      nfs.enable = lib.mkDefault true;
      nh.enable = lib.mkDefault true;
    };
    core = {
      enable = lib.mkDefault true;
      gnupg.enable = lib.mkDefault true;
      developer.enable = lib.mkDefault true;
      plymouth.enable = lib.mkDefault true;
      adb.enable = lib.mkDefault false;
      audio.enable = lib.mkDefault true;
      bluetooth.enable = lib.mkDefault true;
      camera.enable = lib.mkDefault true;
      gnome.enable = lib.mkDefault true;
      mullvad.enable = lib.mkDefault true;
      printing.enable = lib.mkDefault false;
      steam.enable = lib.mkDefault true;
      virtualization.enable = lib.mkDefault true;
      wayland = {
        enable = lib.mkDefault true;
        umbriel.enable = lib.mkDefault true;
        luciole.enable = lib.mkDefault true;
      };
    };
    homelab.groups.enable = lib.mkDefault true;
  };
}
