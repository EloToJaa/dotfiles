{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.modules.homelab.kerberos;
in {
  options.modules.homelab.kerberos = {
    realm = lib.mkOption {
      type = lib.types.str;
      default = "ELOTOJA.COM";
    };
    kdc = lib.mkOption {
      type = lib.types.str;
      default = "server.elotoja.com";
    };
    adminServer = lib.mkOption {
      type = lib.types.str;
      default = cfg.kdc;
    };
    domainRealms = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = {
        ".elotoja.com" = cfg.realm;
        "elotoja.com" = cfg.realm;
        ".eagle-perch.ts.net" = cfg.realm;
        "eagle-perch.ts.net" = cfg.realm;
      };
    };
    nfs = {
      idmapDomain = lib.mkOption {
        type = lib.types.str;
        default = "elotoja.com";
      };
      securityMode = lib.mkOption {
        type = lib.types.enum [
          "krb5"
          "krb5i"
          "krb5p"
        ];
        default = "krb5p";
      };
    };
    kdcServer.enable = lib.mkEnableOption "MIT Kerberos KDC for the homelab realm";
  };

  config = lib.mkIf cfg.kdcServer.enable {
    security.krb5.package = pkgs.krb5;

    services.kerberos_server = {
      enable = true;
      settings.realms.${cfg.realm}.acl = [
        {
          principal = "*/admin@${cfg.realm}";
          access = "all";
        }
        {
          principal = "admin@${cfg.realm}";
          access = "all";
        }
      ];
    };
  };
}
