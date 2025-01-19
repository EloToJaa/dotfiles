{
  variables,
  host,
  ...
}: let
  nfs =
    if (host == "desktop" || host == "server")
    then variables.nfs.local
    else variables.nfs.remote;
in {
  fileSystems."/mnt/Data" = {
    device = "${nfs}:/mnt/Main/Data";
    fsType = "nfs";
    options = ["x-systemd.automount" "noauto" "x-systemd.after=network-online.target" "x-systemd.mount-timeout=10"];
  };
  fileSystems."/mnt/Backups" = {
    device = "${nfs}:/mnt/Main/Backups";
    fsType = "nfs";
    options = ["x-systemd.automount" "noauto" "x-systemd.after=network-online.target" "x-systemd.mount-timeout=10"];
  };
  fileSystems."/mnt/Config" = {
    device = "${nfs}:/mnt/Main/Config";
    fsType = "nfs";
    options = ["x-systemd.automount" "noauto" "x-systemd.after=network-online.target" "x-systemd.mount-timeout=10"];
  };
  fileSystems."/mnt/Media" = {
    device = "${nfs}:/mnt/Main/Media";
    fsType = "nfs";
    options = ["x-systemd.automount" "noauto" "x-systemd.after=network-online.target" "x-systemd.mount-timeout=10"];
  };
  fileSystems."/mnt/ISO" = {
    device = "${nfs}:/mnt/Main/ISO";
    fsType = "nfs";
    options = ["x-systemd.automount" "noauto" "x-systemd.after=network-online.target" "x-systemd.mount-timeout=10"];
  };
}
