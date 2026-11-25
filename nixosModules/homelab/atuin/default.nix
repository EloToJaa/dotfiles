{
  pkgs,
  config,
  lib,
  outputs,
  ...
}: let
  inherit (config.modules) homelab;
  cfg = config.modules.homelab.atuin;
  service = outputs.lib.homelab.mkHomelabService {
    inherit lib config;
    name = "atuin";
    port = 8888;
    dataDir = false;
    glance.icon = "di:atuin";
    gatus = {
      name = "Atuin";
      group = "services";
      path = "/healthz";
    };
  };
in {
  options.modules.homelab.atuin = service.options;
  config = lib.mkMerge [
    service.config
    (lib.mkIf cfg.enable {
      services.atuin = {
        enable = true;
        package = pkgs.atuin;
        openRegistration = false;
        database = {
          uri = null;
          createLocally = false;
        };
      };
      systemd.services.${cfg.name}.serviceConfig = {
        EnvironmentFile = config.clan.core.vars.generators."${cfg.name}-env".files.env.path;
      };

      clan.core.postgresql = {
        databases.${cfg.name} = {
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
          restore.stopOnRestore = ["atuin.service"];
        };
        users.${cfg.name} = {};
      };

      clan.core.vars.generators.${cfg.name} = {
        files.pgpassword.deploy = false;
        runtimeInputs = [pkgs.pwgen];
        script = ''
          pwgen -s 64 1 | tr -d '\n' > "$out/pgpassword"
        '';
      };
      clan.core.vars.generators."${cfg.name}-env" = {
        dependencies = [cfg.name];
        files.env = {};
        script = ''
          printf 'ATUIN_DB_URI=postgresql://${cfg.name}:%s@127.0.0.1:${toString homelab.postgres.port}/${cfg.name}\n' \
            "$(cat "$in/${cfg.name}/pgpassword")" \
            > "$out/env"
        '';
      };
    })
  ];
}
