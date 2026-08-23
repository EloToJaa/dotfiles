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
      cxr = "codex resume";
    };
    # home.packages = [pkgs.llm-agents.codex];
    programs.codex = {
      enable = true;
      package = pkgs.llm-agents.codex;
      context = ./AGENTS.md;
      # settings = {
      #   model = "gpt-5.6-sol";
      #   model_reasoning_effort = "medium";
      #   approvals_reviewer = "auto_review";
      #
      #   analytics.enabled = false;
      #
      #   features = {
      #     memories = true;
      #     prevent_idle_sleep = true;
      #   };
      #
      #   projects."/home/elotoja/Projects/dotfiles/main".trust_level = "trusted";
      #
      #   memories = {
      #     use_memories = true;
      #     generate_memories = true;
      #   };
      #
      #   tui = {
      #     vim_mode_default = true;
      #     notifications = true;
      #     status_line = [
      #       "model-with-reasoning"
      #       "current-dir"
      #       "git-branch"
      #       "pull-request-number"
      #       "context-used"
      #       "total-output-tokens"
      #     ];
      #     status_line_use_colors = true;
      #   };
      # };
    };
  };
}
