{
  host,
  config,
  lib,
  ...
}: let
  inherit (config.settings) nfs;
  inherit (config.modules.homelab) kerberos;
  inherit (kerberos.nfs) securityMode;
  hostname =
    if (host == "desktop" || host == "server")
    then nfs.local
    else nfs.remote;
  options = [
    "x-systemd.automount"
    "noauto"
    "x-systemd.after=network-online.target"
    "x-systemd.mount-timeout=10"
    "_netdev"
    "nfsvers=4.2"
    "sec=${securityMode}"
  ];
  fsType = "nfs";
  cfg = config.modules.base.nfs;
in {
  options.modules.base.nfs = {
    enable = lib.mkEnableOption "Enable nfs";
  };
  config = lib.mkIf cfg.enable {
    security.krb5 = {
      enable = true;
      settings = {
        libdefaults.default_realm = kerberos.realm;
        realms.${kerberos.realm} = {
          kdc = kerberos.kdc;
          admin_server = kerberos.adminServer;
        };
        domain_realm = kerberos.domainRealms;
      };
    };

    services.nfs.idmapd.settings.General.Domain = lib.mkForce kerberos.nfs.idmapDomain;

    fileSystems = {
      "/mnt/Data" = {
        device = "${hostname}:/mnt/Main/Data";
        inherit fsType options;
      };
      "/mnt/Backups" = {
        device = "${hostname}:/mnt/Main/Backups";
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
