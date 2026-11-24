{
  lib,
  config,
  pkgs,
  outputs,
  ...
}: let
  inherit (config.modules) homelab;
  cfg = homelab.matrix;
  issuer = homelab.authelia.url;
  clientId = "MOJkxDPjHOStC2miPgG6dHMoLhx0anQ1Zh5O5KZ9TKQHut1IXp4GCAiS1aMz2GTT";
  callbackUrl = "https://${cfg.endpointDomain}/_matrix/client/unstable/login/sso/callback/${clientId}";
  generatorName = "matrix-oidc";
  oidcGenerator = config.clan.core.vars.generators.${generatorName};
in {
  options.modules.homelab.matrix.auth = {
    enable = lib.mkEnableOption ''
      Tuwunel single sign-on through Authelia. Configures the identity provider on
      the Matrix machine and registers the OIDC client on the Authelia machine
    '';
  };

  config = lib.mkMerge [
    (lib.mkIf (cfg.auth.enable && (cfg.enable || homelab.authelia.enable)) {
      clan.core.vars.generators.${generatorName} = outputs.lib.homelab.mkOidcSecret {
        inherit pkgs;
        share = true;
        secretOwner =
          if cfg.enable
          then "tuwunel"
          else "root";
        hashOwner =
          if homelab.authelia.enable
          then homelab.authelia.name
          else "root";
      };
    })

    (lib.mkIf (cfg.enable && cfg.auth.enable) {
      services.matrix-tuwunel.settings.global = {
        # Older Element clients call /login/sso/redirect without a provider id:
        # https://github.com/matrix-construct/tuwunel/issues/286
        single_sso = true;
        identity_provider = [
          {
            brand = "Authelia";
            name = "Authelia";
            client_id = clientId;
            client_secret_file = oidcGenerator.files.client-secret.path;
            issuer_url = issuer;
            callback_url = callbackUrl;
            trusted = true;
            userid_claims = ["preferred_username"];
          }
        ];
      };
    })

    (lib.mkIf (homelab.authelia.enable && cfg.auth.enable) {
      services.authelia.instances.main.settings.identity_providers.oidc = {
        claims_policies.tuwunel.id_token = [
          "email"
          "name"
          "groups"
          "preferred_username"
        ];
        clients = [
          (outputs.lib.homelab.mkOidcClient {
            hashPath = oidcGenerator.files.client-secret-hash.path;
            client = {
              client_id = clientId;
              client_name = "Matrix";
              claims_policy = "tuwunel";
              redirect_uris = [callbackUrl];
              scopes = ["openid" "email" "profile" "groups"];
              token_endpoint_auth_method = "client_secret_post";
            };
          })
        ];
      };
    })
  ];
}
