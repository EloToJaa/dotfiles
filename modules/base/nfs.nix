{
  variables,
  host,
  ...
}: let
  nfs =
    if (host == "desktop" || host == "server")
    then variables.nfs.local
    else variables.nfs.remote;
  defaultOptions = [
    "x-systemd.automount"
    "noauto"
    "x-systemd.after=network-online.target"
    "x-systemd.mount-timeout=10"
  ];
in {
  fileSystems."/mnt/Data" = {
    device = "${nfs}:/mnt/Main/Data";
    fsType = "nfs";
    options = defaultOptions;
  };
  fileSystems."/mnt/Cloud" = {
    device = "${nfs}:/mnt/Main/Cloud";
    fsType = "nfs";
    options = defaultOptions;
  };
  fileSystems."/mnt/Backups" = {
    device = "${nfs}:/mnt/Main/Backups";
    fsType = "nfs";
    options = defaultOptions;
  };
  fileSystems."/mnt/Photos" = {
    device = "${nfs}:/mnt/Main/Photos";
    fsType = "nfs";
    options = defaultOptions;
  };
  fileSystems."/mnt/Media" = {
    device = "${nfs}:/mnt/Main/Media";
    fsType = "nfs";
    options = defaultOptions;
  };
  fileSystems."/mnt/ISO" = {
    device = "${nfs}:/mnt/Main/ISO";
    fsType = "nfs";
    options = defaultOptions;
  };
  fileSystems."/mnt/Documents" = {
    device = "${nfs}:/mnt/Main/Documents";
    fsType = "nfs";
    options = defaultOptions;
  };
}
