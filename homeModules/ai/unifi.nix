{
  config,
  osConfig,
  lib,
  pkgs,
  ...
}: let
  cfg = config.modules.ai.unifi;
in {
  options.modules.ai.unifi = {
    enable = lib.mkEnableOption "UniFi Network MCP server, giving agents access to the UniFi gateway, devices and clients (writes stay denied by its default policy gates)";
    host = lib.mkOption {
      type = lib.types.str;
      default = "10.11.0.1";
      description = "UniFi OS console the MCP server connects to";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.mcp.servers.unifi = {
      command = lib.getExe pkgs.unifi-network-mcp;
      env = {
        UNIFI_NETWORK_HOST = cfg.host;
        UNIFI_NETWORK_CONTROLLER_TYPE = "proxy";
        UNIFI_SETTINGS_FILE = osConfig.clan.core.vars.generators.unifi-mcp-settings.files."settings.env".path;
      };
    };
  };
}
