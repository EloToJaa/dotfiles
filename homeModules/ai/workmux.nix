{
  config,
  inputs,
  lib,
  pkgs,
  ...
}: let
  cfg = config.modules.ai.workmux;
  workmux = inputs.workmux-skills;
  agent = "claude";
  yaml = pkgs.formats.yaml {};
in {
  options.modules.ai.workmux = {
    enable = lib.mkEnableOption "Enable workmux module";
  };
  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      llm-agents.workmux
    ];
    programs.zsh.zsh-abbr.abbreviations = {
      wm = "workmux";
    };

    xdg.configFile = {
      "opencode/plugins/workmux-status.ts".source = "${workmux}/resources/opencode/plugins/workmux-status.ts";
      "opencode/package.json".source = "${workmux}/resources/opencode/package.json";
    };
    modules.ai.skills = lib.genAttrs [
      "coordinator"
      "merge"
      "open-pr"
      "rebase"
      "workmux"
      "worktree"
    ] (name: "${workmux}/skills/${name}");

    xdg.configFile."workmux/config.yaml".source = yaml.generate "workmux-config.yaml" {
      merge_strategy = "rebase";
      nerdfont = true;
      theme = "dark";
      mode = "window";
      main_branch = "main";
      worktree_dir = "~/.worktrees/{project}";
      worktree_naming = "basename";
      panes = [
        {command = "nvim";}
        {
          command = agent;
          split = "horizontal";
          focus = true;
        }
        {split = "vertical";}
      ];
      status_icons = {
        working = "🤖";
        waiting = "💬";
        done = "✅";
      };
    };
  };
}
