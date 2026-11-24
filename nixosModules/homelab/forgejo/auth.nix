{
  lib,
  config,
  pkgs,
  outputs,
  ...
}: let
  inherit (config.modules) homelab;
  cfg = homelab.forgejo;
  domain = "${cfg.domainName}.${homelab.mainDomain}";
  issuer = "https://${homelab.authelia.domainName}.${homelab.mainDomain}";
  clientId = "jRuwws4w2WzHO1m2w9ytASAFgqsLPTTBcfqNH4UhKPzsR4puEXC08TiyDVwuETN0";
  sourceName = "authelia";
  generatorName = "${cfg.name}-oidc";
  oidcGenerator = config.clan.core.vars.generators.${generatorName};
  forgejo = "${config.services.forgejo.package}/bin/forgejo";
in {
  options.modules.homelab.forgejo.auth = {
    enable = lib.mkEnableOption ''
      Forgejo single sign-on through Authelia. Configures the login source on the
      Forgejo machine and registers the OIDC client on the Authelia machine
    '';
  };

  config = lib.mkMerge [
    (lib.mkIf (cfg.auth.enable && (cfg.enable || homelab.authelia.enable)) {
      clan.core.vars.generators.${generatorName} = outputs.lib.homelab.mkOidcSecret {
        inherit pkgs;
        share = true;
        secretOwner =
          if cfg.enable
          then cfg.name
          else "root";
        hashOwner =
          if homelab.authelia.enable
          then homelab.authelia.name
          else "root";
      };
    })

    (lib.mkIf (cfg.enable && cfg.auth.enable) {
      services.forgejo.settings.oauth2_client = {
        ENABLE_AUTO_REGISTRATION = false;
        ACCOUNT_LINKING = "login";
      };

      # add-oauth/update-oauth fetch the discovery document, so an unreachable
      # Authelia must not keep Forgejo (and its local login fallback) from starting.
      systemd.services.forgejo.preStart = lib.mkAfter ''
        oauth_args=(
          --name ${sourceName}
          --provider openidConnect
          --key ${clientId}
          --secret "$(< ${oidcGenerator.files.client-secret.path})"
          --auto-discover-url ${issuer}/.well-known/openid-configuration
          --scopes openid --scopes email --scopes profile --scopes groups
          --group-claim-name groups
          --skip-local-2fa
        )
        source_id=$(${forgejo} admin auth list | awk -v name=${sourceName} '$2 == name { print $1 }')
        if [ -z "$source_id" ]; then
          ${forgejo} admin auth add-oauth "''${oauth_args[@]}" \
            || echo "warning: could not add the ${sourceName} login source" >&2
        else
          ${forgejo} admin auth update-oauth --id "$source_id" "''${oauth_args[@]}" \
            || echo "warning: could not update the ${sourceName} login source" >&2
        fi
      '';
    })

    (lib.mkIf (homelab.authelia.enable && cfg.auth.enable) {
      services.authelia.instances.main.settings.identity_providers.oidc.clients = [
        (outputs.lib.homelab.mkOidcClient {
          hashPath = oidcGenerator.files.client-secret-hash.path;
          client = {
            client_id = clientId;
            client_name = "Forgejo";
            redirect_uris = ["https://${domain}/user/oauth2/${sourceName}/callback"];
            scopes = ["openid" "email" "profile" "groups"];
          };
        })
      ];
    })
  ];
}
