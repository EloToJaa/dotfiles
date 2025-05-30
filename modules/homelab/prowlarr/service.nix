{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.services.prowlarr;
in {
  options = {
    services.prowlarr = {
      enable = lib.mkEnableOption "Prowlarr, an indexer manager/proxy for Torrent trackers and Usenet indexers";

      dataDir = lib.mkOption {
        type = lib.types.str;
        default = "/var/lib/prowlarr";
        description = "The directory where Prowlarr stores its data files.";
      };

      package = lib.mkPackageOption pkgs "prowlarr" {};

      openFirewall = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Open ports in the firewall for the Prowlarr web interface.";
      };

      user = lib.mkOption {
        type = lib.types.str;
        default = "prowlarr";
        description = ''
          User account under which Prowlarr runs.
        '';
      };

      group = lib.mkOption {
        type = lib.types.str;
        default = "prowlarr";
        description = ''
          Group under which Prowlarr runs.
        '';
      };
    };
  };

  config = lib.mkIf cfg.enable {
    systemd = {
      services.prowlarr = lib.mkForce {
        description = "Prowlarr";
        after = ["network.target"];
        wantedBy = ["multi-user.target"];

        serviceConfig = {
          Type = "simple";
          User = cfg.user;
          Group = cfg.group;
          ExecStart = "${lib.getExe cfg.package} -nobrowser -data='${cfg.dataDir}'";
          Restart = "on-failure";
        };
      };

      tmpfiles.settings."10-prowlarr".${cfg.dataDir}.d = {
        inherit (cfg) user group;
        mode = "0700";
      };
    };

    networking.firewall = lib.mkIf cfg.openFirewall {
      allowedTCPPorts = [cfg.settings.server.port];
    };

    users.users = lib.mkIf (cfg.user == "prowlarr") {
      prowlarr = {
        isSystemUser = true;
        group = cfg.group;
        home = cfg.dataDir;
      };
    };

    users.groups = lib.mkIf (cfg.group == "prowlarr") {
      prowlarr = {};
    };
  };
}
