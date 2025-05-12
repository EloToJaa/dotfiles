{
  variables,
  lib,
  config,
  ...
}: let
  name = "karakeep";
  domainName = "hoarder";
  homelab = variables.homelab;
  group = variables.homelab.groups.main;
  port = 3000;
in {
  services.${name} = {
    enable = true;
    environmentFile = config.sops.templates."${name}.env".path;
    browser.enable = true;
    meilisearch.enable = true;
    extraEnvironment = {
      NEXTAUTH_URL = "https://${domainName}.${homelab.baseDomain}";
      DOMAIN = homelab.baseDomain;
      DATA_DIR = lib.mkForce "${homelab.dataDir}${name}";
      DISABLE_NEW_RELEASE_CHECK = "true";
      PORT = toString port;
    };
  };
  systemd.services.${name}.serviceConfig = {
    User = lib.mkForce name;
    Group = lib.mkForce group;
    UMask = lib.mkForce homelab.defaultUMask;
  };

  services.caddy.virtualHosts."${domainName}.${homelab.baseDomain}" = {
    useACMEHost = homelab.baseDomain;
    extraConfig = ''
      reverse_proxy http://127.0.0.1:${toString port}
    '';
  };

  users.users.${name} = {
    isSystemUser = true;
    group = lib.mkForce group;
  };

  sops.secrets = {
    "${name}/openaiapikey" = {
      owner = name;
    };
  };
  sops.templates."${name}.env".content = ''
    OPENAI_API_KEY=${config.sops.placeholder."${name}/openaiapikey"}
  '';
}
