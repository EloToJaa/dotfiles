{variables, ...}: {
  fileSystems."/mnt/Data" = {
    device = "${variables.nfs}:/mnt/Main/Data";
    fsType = "nfs";
    options = ["x-systemd.automount" "noauto" "x-systemd.after=network-online.target" "x-systemd.mount-timeout=10"];
  };
  fileSystems."/mnt/Backups" = {
    device = "${variables.nfs}:/mnt/Main/Backups";
    fsType = "nfs";
    options = ["x-systemd.automount" "noauto" "x-systemd.after=network-online.target" "x-systemd.mount-timeout=10"];
  };
  fileSystems."/mnt/Config" = {
    device = "${variables.nfs}:/mnt/Main/Config";
    fsType = "nfs";
    options = ["x-systemd.automount" "noauto" "x-systemd.after=network-online.target" "x-systemd.mount-timeout=10"];
  };
  fileSystems."/mnt/Media" = {
    device = "${variables.nfs}:/mnt/Main/Media";
    fsType = "nfs";
    options = ["x-systemd.automount" "noauto" "x-systemd.after=network-online.target" "x-systemd.mount-timeout=10"];
  };
  fileSystems."/mnt/ISO" = {
    device = "${variables.nfs}:/mnt/Main/ISO";
    fsType = "nfs";
    options = ["x-systemd.automount" "noauto" "x-systemd.after=network-online.target" "x-systemd.mount-timeout=10"];
  };
}
