{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.modules.homelab.rustdesk;
  inherit (config.modules) homelab;
in {
  options.modules.homelab.rustdesk = {
    enable = lib.mkEnableOption "Enable rustdesk";
    dataDir = lib.mkOption {
      type = lib.types.path;
      default = "${homelab.varDataDir}rustdesk";
    };
  };
  config = lib.mkIf cfg.enable {
    services.rustdesk-server = {
      enable = true;
      package = pkgs.unstable.rustdesk-server;
      openFirewall = true;
      relay.enable = true;
      signal = {
        enable = true;
        relayHosts = ["127.0.0.1"];
      };
    };

    clan.core.state.rustdesk = {
      folders = [
        cfg.dataDir
      ];
      preBackupScript = ''
        export PATH=${
          lib.makeBinPath [
            config.systemd.package
          ]
        }

        systemctl stop rustdesk-signal.service
        systemctl stop rustdesk-relay.service
      '';

      postBackupScript = ''
        export PATH=${
          lib.makeBinPath [
            config.systemd.package
          ]
        }

        systemctl start rustdesk-signal.service
        systemctl start rustdesk-relay.service
      '';
    };
  };
}
