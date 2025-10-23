{
  host,
  config,
  lib,
  ...
}: let
  inherit (config.settings) nfs;
  hostname =
    if (host == "desktop" || host == "server")
    then nfs.local
    else nfs.remote;
  options = [
    "x-systemd.automount"
    "noauto"
    "x-systemd.after=network-online.target"
    "x-systemd.mount-timeout=10"
  ];
  fsType = "nfs";
  cfg = config.modules.base.nfs;
in {
  options.modules.base.nfs = {
    enable = lib.mkEnableOption "Enable nfs";
  };
  config = lib.mkIf cfg.enable {
    fileSystems = {
      "/mnt/Data" = {
        device = "${hostname}:/mnt/Main/Data";
        inherit fsType options;
      };
      "/mnt/Cloud" = {
        device = "${hostname}:/mnt/Main/Cloud";
        inherit fsType options;
      };
      "/mnt/Backups" = {
        device = "${hostname}:/mnt/Main/Backups";
        inherit fsType options;
      };
      "/mnt/Photos" = {
        device = "${hostname}:/mnt/Main/Photos";
        inherit fsType options;
      };
      "/mnt/Media" = {
        device = "${hostname}:/mnt/Main/Media";
        inherit fsType options;
      };
      "/mnt/ISO" = {
        device = "${hostname}:/mnt/Main/ISO";
        inherit fsType options;
      };
      "/mnt/Documents" = {
        device = "${hostname}:/mnt/Main/Documents";
        inherit fsType options;
      };
    };
  };
}
