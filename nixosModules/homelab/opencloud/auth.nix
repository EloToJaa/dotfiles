{
  lib,
  config,
  ...
}: let
  inherit (config.modules) homelab;
  cfg = config.modules.homelab.opencloud;
  domain = "${cfg.domainName}.${homelab.baseDomain}";
  mkPublicClient = {
    client_id,
    client_name,
    redirect_uris,
  }: {
    inherit client_id client_name redirect_uris;
    public = true;
    authorization_policy = "two_factor";
    require_pkce = true;
    pkce_challenge_method = "S256";
    scopes = [
      "openid"
      "offline_access"
      "groups"
      "profile"
      "email"
    ];
    response_types = ["code"];
    grant_types = [
      "authorization_code"
      "refresh_token"
    ];
    access_token_signed_response_alg = "RS256";
    userinfo_signed_response_alg = "none";
    token_endpoint_auth_method = "none";
  };
in {
  options.modules.homelab.opencloud.auth = {
    enable = lib.mkEnableOption "Enable OpenCloud single sign-on through authelia";
  };
  config = lib.mkIf (cfg.enable && cfg.auth.enable) {
    services.authelia.instances.main.settings.identity_providers.oidc.clients = map mkPublicClient [
      {
        client_id = "web";
        client_name = "OpenCloud";
        redirect_uris = [
          "https://${domain}/"
          "https://${domain}/oidc-callback.html"
          "https://${domain}/oidc-silent-redirect.html"
        ];
      }
      {
        client_id = "OpenCloudDesktop";
        client_name = "OpenCloud Desktop";
        redirect_uris = [
          "http://127.0.0.1"
          "http://localhost"
        ];
      }
      {
        client_id = "OpenCloudAndroid";
        client_name = "OpenCloud Android";
        redirect_uris = ["oc://android.opencloud.eu"];
      }
      {
        client_id = "OpenCloudIOS";
        client_name = "OpenCloud iOS";
        redirect_uris = [
          "oc://ios.opencloud.eu"
          "oc.ios://ios.opencloud.eu"
        ];
      }
    ];
  };
}
