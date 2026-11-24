{
  lib,
  config,
  pkgs,
  outputs,
  ...
}: let
  inherit (config.modules) homelab;
  cfg = config.modules.homelab.yamtrack;
  domain = "${cfg.domainName}.${homelab.baseDomain}";
  issuer = homelab.authelia.url;
  clientId = "ncoHLrQqBY0PdmH0yx6GnP7nkcNvoRKDZcyCNX0IFwVVmGKyaYqa1X6QxkfaD9Wl";
  providerId = "authelia";
  providersGenerator = config.clan.core.vars.generators."${cfg.name}-oidc-providers";
  providers = {
    openid_connect.APPS = [
      {
        provider_id = providerId;
        name = "Authelia";
        client_id = clientId;
        settings = {
          server_url = issuer;
          token_auth_method = "client_secret_basic";
          oauth_pkce_enabled = true;
        };
      }
    ];
  };
in {
  options.modules.homelab.yamtrack.auth = {
    enable = lib.mkEnableOption "Enable Yamtrack single sign-on through authelia";
  };
  config = lib.mkIf (cfg.enable && cfg.auth.enable) (lib.mkMerge [
    (outputs.lib.homelab.mkLocalOidcClient {
      inherit lib config pkgs;
      inherit (cfg) name;
      client = {
        client_id = clientId;
        client_name = "Yamtrack";
        redirect_uris = ["https://${domain}/accounts/oidc/${providerId}/login/callback/"];
      };
    })
    {
      systemd.services = lib.genAttrs ["yamtrack-migrate" "yamtrack" "yamtrack-worker" "yamtrack-beat"] (_: {
        environment = {
          SOCIAL_PROVIDERS = "allauth.socialaccount.providers.openid_connect";
          SOCIALACCOUNT_PROVIDERS_FILE = "%d/providers";
        };
        serviceConfig.LoadCredential = "providers:${providersGenerator.files.providers.path}";
      });

      # Yamtrack lists the file's parent directory, which is unreadable under
      # /run/secrets, so the file is passed through a service credential.
      clan.core.vars.generators."${cfg.name}-oidc-providers" = {
        dependencies = ["${cfg.name}-oidc"];
        runtimeInputs = [pkgs.jq];
        files.providers = {
          owner = cfg.name;
          group = cfg.name;
        };
        script = ''
          jq -c --rawfile secret "$in/${cfg.name}-oidc/client-secret" \
            '.openid_connect.APPS[0].secret = $secret' \
            ${pkgs.writeText "yamtrack-socialaccount-providers.json" (builtins.toJSON providers)} \
            > "$out/providers"
        '';
      };
    }
  ]);
}
