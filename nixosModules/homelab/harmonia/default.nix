{
  lib,
  config,
  pkgs,
  outputs,
  ...
}: let
  inherit (config.modules) homelab;
  cfg = homelab.harmonia;
  service = outputs.lib.homelab.mkHomelabService {
    inherit lib config;
    name = "harmonia";
    port = 5000;
    serviceName = null;
    description = "Enable harmonia binary cache";
    domainName = "cache";
    dataDir = false;
    proxyWebsockets = false;
    glance.icon = "di:nixos";
    gatus = {
      name = "Harmonia";
      group = "ci";
      path = "/nix-cache-info";
    };
  };
  signingKey = config.clan.core.vars.generators.harmonia-signing-key.files;
  domain = "${cfg.domainName}.${homelab.baseDomain}";
in {
  options.modules.homelab.harmonia = service.options;

  config = lib.mkMerge [
    service.config
    (lib.mkIf cfg.enable {
      services.harmonia.cache = {
        enable = true;
        signKeyPaths = [signingKey.secret-key.path];
        settings.bind = "127.0.0.1:${toString cfg.port}";
      };

      # harmonia queries the store through the nix daemon
      nix.settings.allowed-users = ["harmonia"];

      clan.core.vars.generators.harmonia-signing-key = {
        files = {
          secret-key = {};
          public-key.secret = false;
        };
        runtimeInputs = [pkgs.nix];
        script = ''
          nix --extra-experimental-features nix-command key generate-secret --key-name ${domain}-1 > "$out/secret-key"
          nix --extra-experimental-features nix-command key convert-secret-to-public < "$out/secret-key" > "$out/public-key"
        '';
      };

      services.nginx.virtualHosts.${domain}.locations."/".extraConfig = ''
        proxy_redirect http:// https://;
      '';

      # use more cores for compression
      services.nginx.appendConfig = ''
        worker_processes auto;
      '';
    })
  ];
}
