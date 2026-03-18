{
  pkgs,
  config,
  lib,
  inputs,
  ...
}: let
  inherit (config.settings) stateVersion;
  inherit (config.modules) homelab;
  cfg = config.modules.homelab.zeroclaw;
  aiTools = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system};
in {
  options.modules.homelab.zeroclaw = {
    enable = lib.mkEnableOption "Enable zeroclaw";
    name = lib.mkOption {
      type = lib.types.str;
      default = "zeroclaw";
    };
    domainName = lib.mkOption {
      type = lib.types.str;
      default = "claw";
    };
    group = lib.mkOption {
      type = lib.types.str;
      default = homelab.groups.main;
    };
    dataDir = lib.mkOption {
      type = lib.types.path;
      default = "${homelab.varDataDir}${cfg.name}";
    };
    host = lib.mkOption {
      type = lib.types.str;
      default = "192.168.100.21";
    };
    port = lib.mkOption {
      type = lib.types.port;
      default = 42617;
    };
  };
  imports = [
    ./service.nix
  ];
  config = lib.mkIf cfg.enable {
    containers.zeroclaw = {
      autoStart = true;
      privateNetwork = true;
      hostAddress = "192.168.100.20";
      localAddress = cfg.host;
      hostAddress6 = "fc00::1";
      localAddress6 = "fc00::2";
      config = {
        services.zeroclaw = {
          inherit (cfg) group port;
          enable = true;
          package = aiTools.zeroclaw;
          user = cfg.name;
          dataDir = cfg.dataDir;
          environmentFile = config.sops.templates."${cfg.name}.env".path;
        };
        services = {
          resolved.enable = true;
        };
        systemd.tmpfiles.rules = [
          "d ${cfg.dataDir} 750 ${cfg.name} ${cfg.group} - -"
        ];

        system.stateVersion = stateVersion;

        networking = {
          firewall.enable = true;
          # Use systemd-resolved inside the container
          # Workaround for bug https://github.com/NixOS/nixpkgs/issues/162686
          useHostResolvConf = lib.mkForce false;
        };

        users.users.${cfg.name} = {
          isSystemUser = true;
          description = cfg.name;
          group = lib.mkForce cfg.group;
        };
      };
      forwardPorts = [
        {
          containerPort = cfg.port;
          hostPort = cfg.port;
          protocol = "tcp";
        }
      ];
      bindMounts.mediaLocation = {
        isReadOnly = false;
        hostPath = cfg.dataDir;
        mountPoint = cfg.dataDir;
      };
    };

    services.nginx.virtualHosts."${cfg.domainName}.${homelab.baseDomain}" = {
      forceSSL = true;
      useACMEHost = homelab.baseDomain;
      locations."/".proxyPass = "http://${cfg.host}:${toString cfg.port}";
    };
    clan.core.state.zeroclaw = {
      folders = [
        cfg.dataDir
      ];
      preBackupScript = ''
        export PATH=${
          lib.makeBinPath [
            config.systemd.package
          ]
        }

        systemctl stop container@zaroclaw.service
      '';

      postBackupScript = ''
        export PATH=${
          lib.makeBinPath [
            config.systemd.package
          ]
        }

        systemctl start container@zeroclaw.service
      '';
    };

    # Enable NAT for the container
    networking.nat = {
      enable = true;
      # Use "ve-*" when using nftables instead of iptables
      internalInterfaces = ["ve-+"];
      externalInterface = "enp1s0";
      # Lazy IPv6 connectivity for the container
      enableIPv6 = true;
    };

    # SOPS secrets for zeroclaw
    sops.secrets = {
      "${cfg.name}/api_key" = {};
      "${cfg.name}/pgpassword" = {};
    };

    sops.templates."${cfg.name}.env".content = ''
      API_KEY=${config.sops.placeholder."${cfg.name}/api_key"}
      DATABASE_URL=postgresql://${cfg.name}:${config.sops.placeholder."${cfg.name}/pgpassword"}@127.0.0.1:${toString homelab.postgres.port}/${cfg.name}
    '';
  };
}
