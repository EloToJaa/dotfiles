{
  lib,
  config,
  pkgs,
  outputs,
  ...
}: let
  inherit (config.modules) homelab;
  cfg = config.modules.homelab.radarr;
  service = outputs.lib.homelab.mkHomelabService {
    inherit lib config;
    name = "radarr";
    port = 7878;
    gatus = {
      name = "Radarr";
      group = "media";
      path = "/ping";
    };
    umaskUnits = ["radarr"];
  };
in {
  options.modules.homelab.radarr =
    service.options
    // {
      group = lib.mkOption {
        type = lib.types.str;
        default = homelab.groups.media;
      };
      exporterPort = lib.mkOption {
        type = lib.types.port;
        default = 9712;
        description = "Loopback port of the Exportarr instance for radarr";
      };
    };
  config = lib.mkMerge [
    service.config
    (lib.mkIf cfg.enable {
      modules.homelab.prometheus.exportarr.radarr = {
        port = cfg.exporterPort;
        url = "http://127.0.0.1:${toString cfg.port}";
        apiKeyFile = config.clan.core.vars.generators.${cfg.name}.files.apikey.path;
      };

      services.radarr = {
        enable = true;
        package = pkgs.unstable.radarr;
        user = cfg.name;
        inherit (cfg) group dataDir;
      };
      systemd.tmpfiles.rules = [
        "d ${cfg.dataDir} 750 ${cfg.name} ${cfg.group} - -"
        "L+ ${cfg.dataDir}/config.xml - - - - ${config.clan.core.vars.generators."${cfg.name}-config".files.config.path}"
      ];

      clan.core.postgresql = {
        databases = {
          "${cfg.name}-main" = {
            create = {
              enable = true;
              options = {
                LC_COLLATE = "C";
                LC_CTYPE = "C";
                ENCODING = "UTF8";
                OWNER = cfg.name;
                TEMPLATE = "template0";
              };
            };
            restore.stopOnRestore = ["radarr.service"];
          };
          "${cfg.name}-log" = {
            create = {
              enable = true;
              options = {
                LC_COLLATE = "C";
                LC_CTYPE = "C";
                ENCODING = "UTF8";
                OWNER = cfg.name;
                TEMPLATE = "template0";
              };
            };
            restore.stopOnRestore = ["radarr.service"];
          };
        };
        users.${cfg.name} = {};
      };

      users.users.${cfg.name} = {
        isSystemUser = true;
        description = cfg.name;
        inherit (cfg) group;
      };

      clan.core.vars.generators = {
        ${cfg.name} = {
          files = {
            apikey = {};
            pgpassword.deploy = false;
          };
          runtimeInputs = with pkgs; [
            openssl
            pwgen
          ];
          script = ''
            openssl rand -hex 16 | tr -d '\n' > $out/apikey
            pwgen -s 32 1 | tr -d '\n' > $out/pgpassword
          '';
        };
        "${cfg.name}-config" = let
          script = ''
            cat > $out/config <<EOF
            <Config>
              <LogLevel>info</LogLevel>
              <EnableSsl>False</EnableSsl>
              <Port>${toString cfg.port}</Port>
              <SslPort>8787</SslPort>
              <UrlBase></UrlBase>
              <BindAddress>127.0.0.1</BindAddress>
              <AllowedHosts></AllowedHosts>
              <TrustedNetworks></TrustedNetworks>
              <ApiKey>$(cat $in/${cfg.name}/apikey)</ApiKey>
              <AuthenticationMethod>Forms</AuthenticationMethod>
              <LaunchBrowser>True</LaunchBrowser>
              <Branch>master</Branch>
              <InstanceName>Radarr</InstanceName>
              <AuthenticationRequired>Enabled</AuthenticationRequired>
              <SslCertPath></SslCertPath>
              <SslCertPassword></SslCertPassword>
              <PostgresUser>${cfg.name}</PostgresUser>
              <PostgresPassword>$(cat $in/${cfg.name}/pgpassword)</PostgresPassword>
              <PostgresPort>${toString homelab.postgres.port}</PostgresPort>
              <PostgresHost>127.0.0.1</PostgresHost>
              <AnalyticsEnabled>False</AnalyticsEnabled>
              <Theme>auto</Theme>
            </Config>
            EOF
          '';
        in {
          dependencies = [cfg.name];
          files.config.owner = cfg.name;
          inherit script;
          # Re-run the generator whenever the config template changes.
          validation = {inherit script;};
        };
      };
    })
  ];
}
