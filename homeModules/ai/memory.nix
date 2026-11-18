{
  config,
  osConfig,
  lib,
  pkgs,
  ...
}: let
  cfg = config.modules.ai.memory;
  package = pkgs.llm-agents.ai-memory;
  bin = lib.getExe package;
  dataDir = "${config.xdg.dataHome}/ai-memory";
  token_path = osConfig.clan.core.vars.generators.ai-memory-client.files.auth-token.path;

  # Claude Code lifecycle hooks, as `ai-memory install-hooks --agent claude-code` renders them;
  # server URL and token come from the data dir, so no secret lands in settings.json
  claudeHook = event: extra: {
    hooks = [
      ({
          type = "command";
          command = "${bin} --data-dir ${dataDir} hook --event ${event} --agent claude-code";
        }
        // extra)
    ];
  };
in {
  options.modules.ai.memory = {
    enable = lib.mkEnableOption "Enable ai-memory, long-term memory shared across agents and machines";
    serverUrl = lib.mkOption {
      type = lib.types.str;
      default = "https://memory.server.elotoja.com";
      description = "ai-memory server that every harness on this machine reads from and writes to.";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [package];

    xdg.dataFile = {
      "ai-memory/config.toml".source = (pkgs.formats.toml {}).generate "ai-memory.toml" {
        server_url = cfg.serverUrl;
      };
      # hooks and the MCP bridge read the bearer token from <data_dir>/auth-token
      "ai-memory/auth-token".source = config.lib.file.mkOutOfStoreSymlink token_path;
    };

    # MCP tools (search, read/write pages, handoffs) for every harness in the shared registry
    programs.mcp.servers.ai-memory = {
      command = bin;
      args = ["--data-dir" dataDir "mcp-bridge" "--no-session-id"];
    };

    # Claude Code gets the session-aware bridge and the capture hooks
    programs.claude-code = {
      mcpServers.ai-memory = {
        type = "stdio";
        command = bin;
        args = ["--data-dir" dataDir "mcp-bridge"];
      };
      settings.hooks = {
        SessionStart = [(claudeHook "session-start" {})];
        UserPromptSubmit = [(claudeHook "user-prompt-submit" {})];
        PreToolUse = [(claudeHook "pre-tool-use" {})];
        PostToolUse = [(claudeHook "post-tool-use" {})];
        PostToolUseFailure = [(claudeHook "post-tool-use" {})];
        PreCompact = [(claudeHook "pre-compact" {})];
        Stop = [(claudeHook "stop" {})];
        SessionEnd = [(claudeHook "session-end" {timeout = 15;})];
        SubagentStart = [(claudeHook "subagent-start" {})];
        SubagentStop = [(claudeHook "subagent-stop" {})];
      };
    };
  };
}
