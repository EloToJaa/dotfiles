{
  lib,
  config,
  pkgs,
  outputs,
  ...
}: let
  inherit (config.modules) homelab;
  cfg = config.modules.homelab.cleanuparr;
  baseUrl = "https://${cfg.domainName}.${homelab.baseDomain}";
in {
  options.modules.homelab.cleanuparr.auth = {
    enable = lib.mkEnableOption "Enable cleanuparr single sign-on through authelia";
  };
  config = lib.mkIf (cfg.enable && cfg.auth.enable) (outputs.lib.homelab.mkLocalOidcClient {
    inherit lib config pkgs;
    inherit (cfg) name;
    client = {
      client_id = "QVro7yqDxJWfPKErJ9krvxbPcjdPapjLoz2ZvGUYOLZ1uTlcl3XunqbMSFEbWu8r";
      client_name = "Cleanuparr";
      authorization_policy = homelab.authelia.oidcAdminPolicy;
      redirect_uris = [
        "${baseUrl}/api/auth/oidc/callback"
        "${baseUrl}/api/account/oidc/link/callback"
      ];
      token_endpoint_auth_method = "client_secret_post";
    };
  });
}
