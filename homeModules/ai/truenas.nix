{
  config,
  osConfig,
  lib,
  pkgs,
  ...
}: let
  cfg = config.modules.ai.truenas;
in {
  options.modules.ai.truenas = {
    enable = lib.mkEnableOption "TrueNAS MCP server, giving agents read-only access to pools, datasets, shares, apps and system health";
    url = lib.mkOption {
      type = lib.types.str;
      default = "10.11.0.34";
      description = "TrueNAS host or wss:// URL the MCP server connects to";
    };
    apiUser = lib.mkOption {
      type = lib.types.str;
      default = "truenas_admin";
      description = "TrueNAS user that owns the API key";
    };
    insecure = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Skip TLS verification; the default TrueNAS certificate is self-signed and has no IP SAN";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.mcp.servers.truenas = {
      command = lib.getExe pkgs.truenas-mcp;
      args = ["--read-only"];
      env =
        {
          TRUENAS_URL = cfg.url;
          TRUENAS_API_USER = cfg.apiUser;
          TRUENAS_API_KEY_FILE = osConfig.clan.core.vars.generators.truenas-mcp.files.api-key.path;
        }
        // lib.optionalAttrs cfg.insecure {TRUENAS_INSECURE = "1";};
    };
  };
}
