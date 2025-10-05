{
  variables,
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (variables) homelab;
  name = "ntfy-sh";
  domainName = "ntfy";
  group = variables.homelab.groups.main;
  port = 3005;
  dataDir = "${homelab.varDataDir}${name}";
  domain = "${domainName}.${homelab.baseDomain}";
in {
  services.ntfy-sh = {
    inherit group;
    enable = true;
    package = pkgs.unstable.ntfy-sh;
    user = name;
    settings = {
      listen-http = "127.0.0.1:${toString port}";
      cache-file = "${dataDir}/cache.db";
      attachment-cache-dir = "${dataDir}/attachments";
      base-url = "https://${domain}";
      behind-proxy = "true";
    };
  };
  systemd.services.paperless = {
    environment = {
      NTFY_AUTH_FILE = "${dataDir}/auth.db";
      NTFY_ENABLE_LOGIN = "true";
      NTFY_AUTH_DEFAULT_ACCESS = "deny-all";
    };
    serviceConfig = {
      Group = group;
      UMask = lib.mkForce homelab.defaultUMask;
      EnvironmentFile = config.sops.templates."${name}.env".path;
      StateDirectory = lib.mkForce null;
      DynamicUser = lib.mkForce false;
      ProtectSystem = lib.mkForce "off";
    };
  };
  systemd.tmpfiles.rules = [
    "d ${dataDir} 750 ${name} ${group} - -"
  ];

  services.caddy.virtualHosts.${domain} = {
    useACMEHost = homelab.baseDomain;
    extraConfig = ''
      reverse_proxy http://127.0.0.1:${toString port}
    '';
  };

  services.restic.backups.appdata-local.paths = [
    dataDir
  ];

  users.users.${name} = {
    isSystemUser = true;
    description = name;
    group = lib.mkForce group;
  };

  sops.secrets = {
    "${name}/authusers" = {
      owner = name;
    };
  };
  sops.templates."${name}.env" = {
    content = ''
      NTFY_AUTH_USERS=${config.sops.placeholder."${name}/authusers"}
    '';
    owner = name;
  };
}
