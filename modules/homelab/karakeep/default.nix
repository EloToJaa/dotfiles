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
  imports = [
    ./service.nix
    ./meilisearch.nix
  ];
  services.${name} = {
    enable = true;
    webPort = port;
    user = name;
    group = group;
    dataDir = "${homelab.dataDir}${name}";
    settings = {
      MEILI_ADDR = "127.0.0.1:7700";
      NEXTAUTH_URL = "https://${domainName}.${homelab.baseDomain}";
      DOMAIN = homelab.baseDomain;
    };
  };
  systemd.services.${name}.serviceConfig.UMask = lib.mkForce homelab.defaultUMask;

  services.caddy.virtualHosts."${domainName}.${homelab.baseDomain}" = {
    useACMEHost = homelab.baseDomain;
    extraConfig = ''
      reverse_proxy http://127.0.0.1:${toString port}
    '';
  };

  users.users.${name} = {
    isSystemUser = true;
    group = group;
  };

  sops.secrets = {
    "${name}/openaiapikey" = {
      owner = name;
    };
    "${name}/secret" = {
      owner = name;
    };
  };
  sops.templates."${name}.env".content = ''
    OPENAI_API_KEY=${config.sops.placeholder."${name}/openaiapikey"}
    NEXTAUTH_SECRET=${config.sops.placeholder."${name}/secret"}
  '';
}
