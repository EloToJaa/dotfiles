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
    programs.zsh.zsh-abbr.abbreviations = {
      cc = "claude";
    };
    programs.claude-code = {
      enable = true;
      package = pkgs.llm-agents.claude-code;
      context = ./AGENTS.md;
      # settings = {
      #   model = "claude-fable-5[1m]";
      #   effortLevel = "medium";
      #   modelSettings.claude-fable-5.effortLevel = "medium";
      #   tui = "fullscreen";
      # };
    };
  };
}
