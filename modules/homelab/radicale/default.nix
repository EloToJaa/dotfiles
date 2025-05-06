{
  variables,
  lib,
  config,
  ...
}: let
  name = "radicale";
  domainName = "calendar";
  homelab = variables.homelab;
  group = variables.homelab.groups.main;
  port = 5232;
in {
  services.${name} = {
    enable = true;
    settings = {
      server.hosts = ["127.0.0.1:${toString port}"];
      storage.filesystem_folder = "${homelab.dataDir}${name}";
      auth = {
        type = "htpasswd";
        htpasswd_filename = config.sops.secrets."${name}/htpasswd".path;
        htpasswd_encryption = "plain";
      };
    };
  };
  systemd.services.${name}.serviceConfig = {
    User = lib.mkForce name;
    Group = lib.mkForce group;
    UMask = lib.mkForce homelab.defaultUMask;
  };
  systemd.tmpfiles.rules = [
    "d ${homelab.dataDir}${name} 750 ${name} ${group} - -"
  ];

  services.caddy.virtualHosts."${domainName}.${homelab.baseDomain}" = {
    useACMEHost = homelab.baseDomain;
    extraConfig = ''
      reverse_proxy http://127.0.0.1:${toString port}
    '';
  };

  users.users.${name} = {
    isSystemUser = true;
    description = lib.mkForce name;
    group = lib.mkForce group;
  };

  sops.secrets = {
    "${name}/htpasswd" = {
      owner = name;
    };
  };
}
