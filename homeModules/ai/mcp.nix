{lib, ...}: {
  # Shared MCP server registry: define a server once in `programs.mcp.servers`
  # and every agent harness below picks it up, each in its own config format.
  # pi has no MCP support, and T3 Code runs these harnesses, so it inherits their servers.
  config.programs = {
    mcp.enable = lib.mkDefault true;
    claude-code.enableMcpIntegration = lib.mkDefault true;
    codex.enableMcpIntegration = lib.mkDefault true;
    opencode.enableMcpIntegration = lib.mkDefault true;
  };
}
