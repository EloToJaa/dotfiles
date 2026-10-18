{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (config.modules) homelab;
  cfg = homelab.harmonia;
  signingKey = config.clan.core.vars.generators.harmonia-signing-key.files;
  domain = "${cfg.domainName}.${homelab.baseDomain}";
in {
  options.modules.homelab.harmonia = {
    enable = lib.mkEnableOption "Enable harmonia binary cache";
    domainName = lib.mkOption {
      type = lib.types.str;
      default = "cache";
    };
    port = lib.mkOption {
      type = lib.types.port;
      default = 5000;
    };
  };

  config = lib.mkIf cfg.enable {
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

    services.nginx.virtualHosts.${domain} = {
      forceSSL = true;
      useACMEHost = homelab.baseDomain;
      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString cfg.port}";
        extraConfig = ''
          proxy_redirect http:// https://;
        '';
      };
    };

    # use more cores for compression
    services.nginx.appendConfig = ''
      worker_processes auto;
    '';
  };
}
