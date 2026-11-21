{
  config,
  osConfig,
  lib,
  pkgs,
  ...
}: let
  cfg = config.modules.ai.grafana;
in {
  options.modules.ai.grafana = {
    enable = lib.mkEnableOption "Grafana MCP server, giving agents read access to homelab dashboards, Prometheus metrics and Loki logs";
    url = lib.mkOption {
      type = lib.types.str;
      default = "https://grafana.server.elotoja.com";
      description = "Grafana instance the MCP server talks to";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.mcp.servers.grafana = {
      command = lib.getExe pkgs.unstable.mcp-grafana;
      args = ["--disable-write"];
      env = {
        GRAFANA_URL = cfg.url;
        GRAFANA_SERVICE_ACCOUNT_TOKEN_FILE = osConfig.clan.core.vars.generators.grafana-mcp.files.token.path;
      };
    };
  };
}
