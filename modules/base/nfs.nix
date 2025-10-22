{
  host,
  config,
  lib,
  ...
}: let
  inherit (config.modules) settings;
  nfs =
    if (host == "desktop" || host == "server")
    then settings.nfs.local
    else settings.nfs.remote;
  options = [
    "x-systemd.automount"
    "noauto"
    "x-systemd.after=network-online.target"
    "x-systemd.mount-timeout=10"
  ];
  fsType = "nfs";
in {
  options.modules.base.nfs = {
    enable = lib.mkEnableOption "Enable nfs";
  };
  config = lib.mkIf config.modules.base.nfs.enable {
    fileSystems = {
      "/mnt/Data" = {
        device = "${nfs}:/mnt/Main/Data";
        inherit fsType options;
      };
      "/mnt/Cloud" = {
        device = "${nfs}:/mnt/Main/Cloud";
        inherit fsType options;
      };
      "/mnt/Backups" = {
        device = "${nfs}:/mnt/Main/Backups";
        inherit fsType options;
      };
      "/mnt/Photos" = {
        device = "${nfs}:/mnt/Main/Photos";
        inherit fsType options;
      };
      "/mnt/Media" = {
        device = "${nfs}:/mnt/Main/Media";
        inherit fsType options;
      };
      "/mnt/ISO" = {
        device = "${nfs}:/mnt/Main/ISO";
        inherit fsType options;
      };
      "/mnt/Documents" = {
        device = "${nfs}:/mnt/Main/Documents";
        inherit fsType options;
      };
    };
  };
}
