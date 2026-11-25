{
  lib,
  config,
  pkgs,
  outputs,
  ...
}: let
  inherit (config.modules) homelab;
  cfg = config.modules.homelab.paperless;
  service = outputs.lib.homelab.mkHomelabService {
    inherit lib config;
    name = "paperless";
    port = 28981;
    domainName = "docs";
    glance.icon = "di:paperless-ngx";
    gatus = {
      name = "Paperless-ngx";
      group = "apps";
      conditions = ["[STATUS] < 400"];
    };
    umaskUnits = ["paperless"];
  };
  domain = "${cfg.domainName}.${homelab.baseDomain}";
in {
  imports = [
    ./auth.nix
  ];
  options.modules.homelab.paperless =
    service.options
    // {
      group = lib.mkOption {
        type = lib.types.str;
        default = homelab.groups.docs;
      };
      mediaDir = lib.mkOption {
        type = lib.types.path;
        default = "${homelab.dataDir}docs";
      };
    };
  config = lib.mkMerge [
    service.config
    (lib.mkIf cfg.enable {
      services.paperless = {
        inherit domain;
        inherit (cfg) port dataDir mediaDir;
        enable = true;
        # nixpkgs ships torch 2.15 but paperless-ngx 3.4.2 pins torch<2.15.
        # makeOverridable keeps `.override`, which the NixOS module calls.
        # Paperless's own ocrmypdf build isn't cached, and its validation timing test
        # fails when the build host is busy.
        package = lib.makeOverridable (args:
          (pkgs.unstable.paperless-ngx.override (args
            // {
              extraPythonPackageOverrides = _final: prev: {
                ocrmypdf = prev.ocrmypdf.overridePythonAttrs (old: {
                  disabledTests = (old.disabledTests or []) ++ ["test_validation_performance"];
                });
              };
            })).overridePythonAttrs (old: {
            pythonRelaxDeps = old.pythonRelaxDeps ++ ["torch"];
          })) {};
        user = cfg.name;
        environmentFile = config.clan.core.vars.generators."${cfg.name}-env".files.env.path;
        settings = {
          # Paperless 3 removed NLTK; the stable NixOS module still defaults to enabling it.
          PAPERLESS_ENABLE_NLTK = false;
          PAPERLESS_ALLOWED_HOSTS = "127.0.0.1";
          PAPERLESS_DBENGINE = "postgresql";
          PAPERLESS_DBHOST = "127.0.0.1";
          PAPERLESS_DBNAME = "paperless";
          PAPERLESS_DBUSER = cfg.name;
          # PAPERLESS_TIKA_ENABLED = "1";
          # PAPERLESS_TIKA_GOTENBERG_ENDPOINT = "http://127.0.0.1:3000";
          # PAPERLESS_TIKA_ENDPOINT = "http://127.0.0.1:9998";
          PAPERLESS_CONSUMER_IGNORE_PATTERN = [
            ".DS_STORE/*"
            "desktop.ini"
          ];
          PAPERLESS_OCR_LANGUAGE = "pol+eng";
          PAPERLESS_OCR_USER_ARGS = {
            optimize = 1;
            pdfa_image_compression = "lossless";
          };
        };
      };
      systemd.services.paperless.serviceConfig = {
        Group = lib.mkForce cfg.group;
      };
      # The upstream web startup script replaces the clan vars key with a generated file,
      # so web uploads fail HMAC verification in the Celery worker.
      systemd.services.paperless-web.script = lib.mkForce ''
        if [[ -z "$PAPERLESS_SECRET_KEY" ]]; then
          echo "PAPERLESS_SECRET_KEY is empty, refusing to start."
          exit 1
        fi
        exec ${lib.getExe config.services.paperless.package.python.pkgs.granian} --interface asginl --ws "paperless.asgi:application"
      '';
      systemd.tmpfiles.rules = [
        "d ${cfg.dataDir} 750 ${cfg.name} ${cfg.group} - -"
      ];

      services.nginx.virtualHosts.${domain}.extraConfig = ''
        client_max_body_size 1000M;
      '';

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
          restore.stopOnRestore = ["paperless-scheduler.service"];
        };
        users.${cfg.name} = {};
      };
      clan.core.state.paperless = {
        folders = [
          cfg.dataDir
          cfg.mediaDir
        ];
        preBackupScript = ''
          export PATH=${
            lib.makeBinPath [
              config.systemd.package
            ]
          }

          systemctl stop paperless-scheduler.service
        '';

        postBackupScript = ''
          export PATH=${
            lib.makeBinPath [
              config.systemd.package
            ]
          }

          systemctl start paperless-scheduler.service
        '';
      };

      users.users.${cfg.name} = {
        isSystemUser = true;
        description = cfg.name;
        group = lib.mkForce cfg.group;
      };

      clan.core.vars.generators = {
        ${cfg.name} = {
          files = {
            pgpassword.deploy = false;
            secretkey.deploy = false;
          };
          runtimeInputs = [pkgs.pwgen];
          script = ''
            pwgen -s 64 1 > "$out/pgpassword"
            pwgen -s 64 1 > "$out/secretkey"
          '';
        };
        "${cfg.name}-env" = {
          dependencies = [cfg.name];
          files.env.owner = cfg.name;
          script = ''
            {
              printf 'PAPERLESS_DBPASS=%s\n' "$(cat "$in/${cfg.name}/pgpassword")"
              printf 'PAPERLESS_SECRET_KEY=%s\n' "$(cat "$in/${cfg.name}/secretkey")"
            } > "$out/env"
          '';
        };
      };
    })
  ];
}
