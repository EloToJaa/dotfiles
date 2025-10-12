{
  variables,
  pkgs,
  ...
}: let
  inherit (variables) homelab;
  name = "hass";
  port = 8123;
  dataDir = "${homelab.dataDir}${name}";
in {
  services.home-assistant = {
    enable = true;
    package = pkgs.unstable.home-assistant.overrideAttrs (_: {
      doInstallCheck = false;
    });
    configDir = dataDir;
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
      };
    };
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
