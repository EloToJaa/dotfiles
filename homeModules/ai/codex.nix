{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.modules.ai.codex;
in {
  options.modules.ai.codex = {
    enable = lib.mkEnableOption "Enable Codex module";
  };

  config = lib.mkIf cfg.enable {
    programs.zsh.zsh-abbr.abbreviations = {
      cx = "codex";
    };
    programs.codex = {
      enable = true;
      package = pkgs.llm-agents.codex;
      context = ./AGENTS.md;
      settings = {
        model = "gpt-5.6";
        approval_policy = "on-request";
        sandbox_mode = "workspace-write";
      };
    };
  };
}
