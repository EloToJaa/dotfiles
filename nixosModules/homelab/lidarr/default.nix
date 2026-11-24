{
  lib,
  config,
  pkgs,
  outputs,
  ...
}: let
  inherit (config.modules) homelab;
  cfg = config.modules.homelab.lidarr;
  service = outputs.lib.homelab.mkHomelabService {
    inherit lib config;
    name = "lidarr";
    port = 8686;
    umaskUnits = ["lidarr"];
  };
in {
  options.modules.homelab.lidarr =
    service.options
    // {
      group = lib.mkOption {
        type = lib.types.str;
        default = homelab.groups.media;
      };
    };
  config = lib.mkMerge [
    service.config
    (lib.mkIf cfg.enable {
      services.lidarr = {
        enable = true;
        package = pkgs.unstable.lidarr;
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
            restore.stopOnRestore = ["lidarr.service"];
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
            restore.stopOnRestore = ["lidarr.service"];
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
            apikey.deploy = false;
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
              <SslPort>6868</SslPort>
              <UrlBase></UrlBase>
              <BindAddress>127.0.0.1</BindAddress>
              <AllowedHosts></AllowedHosts>
              <TrustedNetworks></TrustedNetworks>
              <ApiKey>$(cat $in/${cfg.name}/apikey)</ApiKey>
              <AuthenticationMethod>Forms</AuthenticationMethod>
              <LaunchBrowser>True</LaunchBrowser>
              <Branch>master</Branch>
              <InstanceName>Lidarr</InstanceName>
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
