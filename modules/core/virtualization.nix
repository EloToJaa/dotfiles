{
  pkgs,
  lib,
  config,
  ...
}: let
  inherit (config.settings) username;
  cfg = config.modules.core.virtualization;
in {
  options.modules.core.virtualization = {
    enable = lib.mkEnableOption "Enable virtualization module";
  };
  config = lib.mkIf cfg.enable {
    # Add user to libvirtd group
    users.users.${username}.extraGroups = ["libvirtd"];

    # Install necessary packages
    environment.systemPackages = with pkgs.unstable; [
      virt-manager
      virt-viewer
      spice
      spice-gtk
      spice-protocol
      virtio-win
      win-spice
      adwaita-icon-theme
    ];

    # Manage the virtualisation services
    virtualisation = {
      libvirtd = {
        enable = true;
        package = pkgs.unstable.libvirt;
        qemu = {
          swtpm.enable = true;
          ovmf.enable = true;
          ovmf.packages = [pkgs.OVMFFull.fd];
        };
      };
      spiceUSBRedirection.enable = true;
    };
    services.spice-vdagentd.enable = true;
  };
}
