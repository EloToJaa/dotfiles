{config, ...}: let
  name = "meilisearch";
  port = 7700;
in {
  services.${name} = {
    enable = true;
    listenPort = port;
    noAnalytics = true;
    environment = "production";
  };

  sops.secrets = {
    "${name}/masterkey" = {
      owner = name;
    };
  };
  sops.templates."${name}.env".content = ''
    MEILI_MASTER_KEY=${config.sops.placeholder."${name}/masterkey"}
  '';
}
