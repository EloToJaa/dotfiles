{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (config.modules) homelab;
  cfg = homelab.matrix;
  domain = "${cfg.domainName}.${homelab.baseDomain}";
  serverCertificate =
    if cfg.serverName == homelab.baseDomain || lib.hasSuffix ".${homelab.baseDomain}" cfg.serverName
    then homelab.baseDomain
    else homelab.mainDomain;
  wellKnownHeaders = ''
    default_type application/json;
    add_header Access-Control-Allow-Origin "*" always;
    add_header X-Frame-Options SAMEORIGIN always;
    add_header X-Content-Type-Options nosniff always;
    add_header X-XSS-Protection "1; mode=block" always;
  '';
in {
  options.modules.homelab.matrix = {
    enable = lib.mkEnableOption "Enable the Tuwunel Matrix homeserver";
    domainName = lib.mkOption {
      type = lib.types.str;
      default = "matrix";
      description = "Subdomain under the homelab base domain used for the homeserver URL.";
    };
    serverName = lib.mkOption {
      type = lib.types.str;
      default = homelab.mainDomain;
      description = "Domain used in Matrix user IDs. Changing it after first use requires a new homeserver.";
    };
    port = lib.mkOption {
      type = lib.types.port;
      default = 6167;
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion =
          cfg.serverName
          == homelab.mainDomain
          || cfg.serverName == homelab.baseDomain
          || lib.hasSuffix ".${homelab.mainDomain}" cfg.serverName;
        message = "Matrix serverName must be covered by the homelab ACME certificates.";
      }
    ];

    services.matrix-tuwunel = {
      enable = true;
      settings.global = {
        server_name = cfg.serverName;
        port = [cfg.port];
        max_request_size = 104857600;
        allow_registration = true;
        registration_token_file = config.clan.core.vars.generators.matrix-registration.files.token.path;
        allow_federation = true;
      };
    };
    systemd.services.tuwunel.serviceConfig.DynamicUser = lib.mkForce false;

    clan.core.vars.generators.matrix-registration = {
      files.token = {
        owner = "tuwunel";
        group = "tuwunel";
      };
      runtimeInputs = [pkgs.pwgen];
      script = ''
        mkdir -p "$out"
        pwgen -s 64 1 > "$out/token"
      '';
    };

    services.nginx.virtualHosts = lib.mkMerge [
      {
        ${domain} = {
          forceSSL = true;
          useACMEHost = homelab.baseDomain;
          locations."/_matrix/" = {
            proxyPass = "http://127.0.0.1:${toString cfg.port}";
            extraConfig = ''
              client_max_body_size 100M;
            '';
          };
        };
      }
      {
        ${cfg.serverName} = {
          forceSSL = true;
          useACMEHost = serverCertificate;
          locations = {
            "= /.well-known/matrix/server" = {
              extraConfig = wellKnownHeaders;
              return = "200 '${builtins.toJSON {"m.server" = "${domain}:443";}}'";
            };
            "= /.well-known/matrix/client" = {
              extraConfig = wellKnownHeaders;
              return = "200 '${builtins.toJSON {"m.homeserver" = {base_url = "https://${domain}";};}}'";
            };
          };
        };
      }
    ];

    clan.core.state.tuwunel = {
      folders = ["/var/lib/${config.services.matrix-tuwunel.stateDirectory}"];
      preBackupScript = ''
        export PATH=${lib.makeBinPath [config.systemd.package]}
        systemctl stop tuwunel.service
      '';
      postBackupScript = ''
        export PATH=${lib.makeBinPath [config.systemd.package]}
        systemctl start tuwunel.service
      '';
    };
  };
}
