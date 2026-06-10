{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.modules.homelab.kerberos;
in {
  options.modules.homelab.kerberos = {
    enable = lib.mkEnableOption "MIT Kerberos KDC for the homelab realm";
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
  };

  config = lib.mkIf cfg.enable {
    security.krb5 = {
      enable = true;
      package = pkgs.krb5;
      settings = {
        libdefaults.default_realm = cfg.realm;
        realms.${cfg.realm} = {
          inherit (cfg) kdc;
          admin_server = cfg.adminServer;
        };
        domain_realm = cfg.domainRealms;
      };
    };

    systemd.services.krb5kdc-init = {
      description = "Initialize MIT Kerberos KDC database";
      before = [
        "kdc.service"
        "kadmind.service"
      ];
      requiredBy = [
        "kdc.service"
        "kadmind.service"
      ];
      path = [
        pkgs.coreutils
        pkgs.krb5
        pkgs.openssl
      ];
      environment.KRB5_KDC_PROFILE = "/etc/krb5kdc/kdc.conf";
      serviceConfig = {
        Type = "oneshot";
        StateDirectory = "krb5kdc";
      };
      script = ''
        set -eu

        database=/var/lib/krb5kdc/principal
        master_key=/var/lib/krb5kdc/master-key

        if [ -e "$database" ]; then
          exit 0
        fi

        if [ ! -e "$master_key" ]; then
          umask 077
          openssl rand -base64 48 > "$master_key"
        fi

        chmod 600 "$master_key"
        read -r password < "$master_key"
        kdb5_util -r ${lib.escapeShellArg cfg.realm} -P "$password" create -s
      '';
    };

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
