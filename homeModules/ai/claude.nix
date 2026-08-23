{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.modules.ai.claude;
in {
  options.modules.ai.claude = {
    enable = lib.mkEnableOption "Enable Claude Code module";
  };

  config = lib.mkIf cfg.enable {
    programs.claude-code = {
      enable = true;
      package = pkgs.llm-agents.claude-code;
      context = ./AGENTS.md;
      settings.tui = "fullscreen";
    };
  };
}
