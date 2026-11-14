{
  config,
  osConfig,
  lib,
  pkgs,
  ...
}: let
  cfg = config.modules.ai.claude;
  token_path = osConfig.clan.core.vars.generators.anthropic.files.auth-token.path;
in {
  options.modules.ai.claude = {
    enable = lib.mkEnableOption "Enable Claude Code module";
  };

  config = lib.mkIf cfg.enable {
    programs.zsh.zsh-abbr.abbreviations = {
      cc = "claude";
    };
    programs.claude-code = {
      enable = true;
      # use the terminal cursor instead of a painted block, so the shape follows vi mode;
      # set on the binary since hm-session-vars is only sourced once per login
      package = pkgs.symlinkJoin {
        inherit (pkgs.llm-agents.claude-code) pname version meta;
        paths = [pkgs.llm-agents.claude-code];
        nativeBuildInputs = [pkgs.makeWrapper];
        postBuild = ''
          wrapProgram $out/bin/claude \
            --set CLAUDE_CODE_NATIVE_CURSOR 1 \
            --run 'export ANTHROPIC_AUTH_TOKEN="$(cat ${token_path})"'
        '';
      };
      context = ../AGENTS.md;
      settings = {
        # ANTHROPIC_AUTH_TOKEN is a secret: the claude wrapper reads it from the
        # `anthropic` clan vars generator at runtime so it stays out of the store
        env = {
          ANTHROPIC_BASE_URL = "https://hub.server.elotoja.com";
          CLAUDE_CODE_ENABLE_GATEWAY_MODEL_DISCOVERY = "1";
          API_TIMEOUT_MS = "600000";
          BASH_DEFAULT_TIMEOUT_MS = "600000";
          BASH_MAX_TIMEOUT_MS = "600000";
          CLAUDE_API_TIMEOUT = "600000";
          CLAUDE_CODE_MAX_CONTEXT_TOKENS = "200000";
          CLAUDE_AUTOCOMPACT_PCT_OVERRIDE = "95";
          DISABLE_TELEMETRY = "1";
          MCP_TIMEOUT = "30000";
          MCP_TOOL_TIMEOUT = "600000";
        };
        permissions.defaultMode = "auto";
        model = "sonnet";
        effortLevel = "high";
        tui = "fullscreen";
        editorMode = "vim";
        verbose = true;
        autoCompactEnabled = true;
        skipDangerousModePermissionPrompt = true;
        skipWorkflowUsageWarning = true;
        worktree.baseRef = "fresh";
        enabledPlugins."pyright-lsp@claude-plugins-official" = true;
        hooks = let
          workmux = matcher: command:
            lib.optionalAttrs (matcher != null) {inherit matcher;}
            // {
              hooks = [
                {
                  type = "command";
                  inherit command;
                }
              ];
            };
        in {
          Notification = [(workmux "permission_prompt|elicitation_dialog" "workmux set-window-status waiting")];
          PostToolUse = [(workmux null "workmux set-window-status working")];
          SessionStart = [(workmux "startup|resume|clear|fork" "workmux register-agent")];
          Stop = [(workmux null "workmux set-window-status done")];
          UserPromptSubmit = [(workmux null "workmux set-window-status working")];
        };
      };
    };
    home.file.".claude/keybindings.json".source = ./keybindings.json;
  };
}
