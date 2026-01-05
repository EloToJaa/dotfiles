{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (config.modules) homelab;
  cfg = config.modules.homelab.jellyfin;
in {
  options.modules.homelab.jellyfin = {
    enable = lib.mkEnableOption "Enable jellyfin";
    name = lib.mkOption {
      type = lib.types.str;
      default = "jellyfin";
    };
    domainName = lib.mkOption {
      type = lib.types.str;
      default = "watch";
    };
    group = lib.mkOption {
      type = lib.types.str;
      default = homelab.groups.media;
    };
    port = lib.mkOption {
      type = lib.types.port;
      default = 8096;
    };
    dataDir = lib.mkOption {
      type = lib.types.path;
      default = "${homelab.dataDir}${cfg.name}";
    };
    logDir = lib.mkOption {
      type = lib.types.path;
      default = "${homelab.logDir}${cfg.name}";
    };
  };
  config = lib.mkIf cfg.enable {
    services.jellyfin = {
      enable = true;
      package = pkgs.unstable.jellyfin;
      user = cfg.name;
      inherit (cfg) group dataDir logDir;
    };
    systemd.services.jellyfin.serviceConfig.UMask = lib.mkForce homelab.defaultUMask;
    systemd.tmpfiles.rules = [
      "d ${cfg.dataDir} 750 ${cfg.name} ${cfg.group} - -"
      "d ${cfg.logDir} 750 ${cfg.name} ${cfg.group} - -"
    ];
    services.restic.backups.appdata-local.paths = [
      cfg.dataDir
    ];

    services.caddy.virtualHosts = let
      extraConfig = ''
        reverse_proxy http://127.0.0.1:${toString cfg.port}
      '';
    in {
      "${cfg.domainName}.${homelab.baseDomain}" = {
        inherit extraConfig;
        useACMEHost = homelab.baseDomain;
      };
      "${cfg.domainName}.${homelab.mainDomain}" = {
        inherit extraConfig;
        useACMEHost = homelab.mainDomain;
      };
    };

    users.users.${cfg.name} = {
      isSystemUser = true;
      description = cfg.name;
      inherit (cfg) group;
    };

    services.authelia.instances.main.settings.identity_providers.oidc.clients = [
      {
        client_id = "jellyfin";
        client_name = "Jellyfin";
        client_secret = "{{ secret \"${config.sops.secrets."authelia/secrets/jellyfin".path}\" }}";
        # client_secret = "$pbkdf2-sha512$310000$cTHnJRI3f4bMzovEE3Rung$wU/EM/Kx5NITvlEagpAS0tYUPQEvkbloCYOmwT6W4K5RFew9XXsV5dm52torJQF.3EKMvNZGa5oyf5c3lgjDiA";
        public = false;
        authorization_policy = "two_factor";
        require_pkce = true;
        pkce_challenge_method = "S256";
        redirect_uris = [
          "https://${cfg.domainName}.${homelab.mainDomain}/sso/OID/redirect/authelia"
        ];
        scopes = [
          "openid"
          "profile"
          "groups"
        ];
        response_types = [
          "code"
        ];
        grant_types = [
          "authorization_code"
        ];
        access_token_signed_response_alg = "none";
        userinfo_signed_response_alg = "none";
        token_endpoint_auth_method = "client_secret_post";
      }
    ];

    sops.secrets = {
      "authelia/secrets/jellyfin" = {
        owner = "authelia";
      };
    };
  };
}
