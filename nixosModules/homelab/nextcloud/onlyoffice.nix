{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (config.modules) homelab;
  cfg = config.modules.homelab.nextcloud.onlyoffice;
  domain = "${cfg.domainName}.${homelab.baseDomain}";
in {
  options.modules.homelab.nextcloud.onlyoffice = {
    enable = lib.mkEnableOption "Enable onlyoffice";
    name = lib.mkOption {
      type = lib.types.str;
      default = "onlyoffice";
    };
    domainName = lib.mkOption {
      type = lib.types.str;
      default = "office";
    };
    dataDir = lib.mkOption {
      type = lib.types.path;
      default = "${homelab.varDataDir}${cfg.name}";
    };
  };
  config = lib.mkIf cfg.enable {
    services.onlyoffice = {
      enable = true;
      package = pkgs.unstable.onlyoffice-documentserver;
      hostname = domain;
      port = 13444;

      postgresHost = "/run/postgresql";

      # jwtSecretFile = cfg.apps.onlyoffice.jwtSecretFile;
    };

    sops.secrets = {
      "${cfg.name}/adminpassword" = {
        owner = cfg.name;
      };
      "${cfg.name}/pgpassword" = {
        owner = cfg.name;
      };
    };
  };
}
