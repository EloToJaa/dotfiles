{
  variables,
  pkgs,
  ...
}: let
  inherit (variables) homelab;
  name = "hass";
  port = 8123;
  dataDir = "${homelab.varDataDir}${name}";
in {
  services.home-assistant = {
    enable = true;
    package = pkgs.unstable.home-assistant.overrideAttrs (_: {
      doInstallCheck = false;
    });
    configDir = dataDir;
    configWritable = true;
    config = {
      homeassistant = {
        name = "Home";
        unit_system = "metric";
        temperature_unit = "C";
        time_zone = variables.timezone;
      };
      http = {
        server_host = "127.0.0.1";
        server_port = port;
        use_x_forwarded_for = true;
        trusted_proxies = ["127.0.0.1"];
      };
    };
    extraComponents = [
      # Components required to complete the onboarding
      "analytics"
      "google_translate"
      "met"
      "radio_browser"
      "shopping_list"
      # Recommended for fast zlib compression
      # https://www.home-assistant.io/integrations/isal
      "isal"

      "roomba"
      "xiaomi_miio"
    ];
  };
  services.restic.backups.appdata-local.paths = [
    dataDir
  ];

  services.caddy.virtualHosts."${name}.${homelab.baseDomain}" = {
    useACMEHost = homelab.baseDomain;
    extraConfig = ''
      reverse_proxy http://127.0.0.1:${toString port}
    '';
  };
}
