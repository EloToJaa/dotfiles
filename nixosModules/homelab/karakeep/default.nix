{
  lib,
  config,
  pkgs,
  outputs,
  ...
}: let
  inherit (config.modules) homelab;
  cfg = config.modules.homelab.karakeep;
  service = outputs.lib.homelab.mkHomelabService {
    inherit lib config;
    name = "karakeep";
    port = 3003;
    domainName = "hoarder";
    gatus = {
      name = "Karakeep";
      group = "apps";
      path = "/api/health";
    };
    umaskUnits = [
      "karakeep-init"
      "karakeep-web"
      "karakeep-workers"
    ];
  };
  fontsConf = pkgs.makeFontsConf {
    fontDirectories = with pkgs; [
      dejavu_fonts
      liberation_ttf
      noto-fonts
    ];
  };
in {
  imports = [
    ./auth.nix
  ];
  options.modules.homelab.karakeep =
    service.options
    // {
      group = lib.mkOption {
        type = lib.types.str;
        default = homelab.groups.main;
      };
    };
  config = lib.mkMerge [
    service.config
    (lib.mkIf cfg.enable {
      services.karakeep = {
        enable = true;
        package = pkgs.unstable.karakeep;
        environmentFile = config.clan.core.vars.generators."${cfg.name}-env".files.env.path;
        browser.enable = true;
        meilisearch.enable = true;
        extraEnvironment = {
          NEXTAUTH_URL = "https://${cfg.domainName}.${homelab.baseDomain}";
          DOMAIN = homelab.baseDomain;
          DISABLE_NEW_RELEASE_CHECK = "true";
          PORT = toString cfg.port;
        };
      };
      systemd.services =
        {
          karakeep-browser.environment.FONTCONFIG_FILE = fontsConf;
        }
        // lib.genAttrs [
          "karakeep-init"
          "karakeep-web"
          "karakeep-workers"
        ] (_: {
          serviceConfig = {
            Group = lib.mkForce cfg.group;
          };
        });
      systemd.tmpfiles.rules = [
        "d ${cfg.dataDir} 750 ${cfg.name} ${cfg.group} - -"
      ];

      clan.core.state.karakeep = {
        folders = [
          cfg.dataDir
        ];
        preBackupScript = ''
          export PATH=${
            lib.makeBinPath [
              config.systemd.package
            ]
          }

          systemctl stop karakeep-browser.service
          systemctl stop karakeep-init.service
          systemctl stop karakeep-web.service
          systemctl stop karakeep-workers.service
        '';

        postBackupScript = ''
          export PATH=${
            lib.makeBinPath [
              config.systemd.package
            ]
          }

          systemctl start karakeep-browser.service
          systemctl start karakeep-init.service
          systemctl start karakeep-web.service
          systemctl start karakeep-workers.service
        '';
      };

      users.users.${cfg.name} = {
        isSystemUser = true;
        group = lib.mkForce cfg.group;
      };

      clan.core.vars.generators = {
        ${cfg.name} = {
          prompts.openaiapikey = {
            description = "OpenAI API key for karakeep";
            type = "hidden";
            persist = true;
          };
          files.openaiapikey.deploy = false;
        };
        "${cfg.name}-env" = {
          dependencies = [cfg.name];
          files.env.owner = cfg.name;
          script = ''
            printf 'OPENAI_API_KEY=%s\n' "$(cat "$in/${cfg.name}/openaiapikey")" > "$out/env"
          '';
        };
      };
    })
  ];
}
