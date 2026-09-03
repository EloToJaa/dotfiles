{
  config,
  lib,
  pkgs,
  settings,
  ...
}: let
  cfg = config.modules.ai.workmux;
  workmux = pkgs.callPackage ./pkgs/workmux-skills.nix {};
  inherit (settings) isServer;
  agent =
    if isServer
    then "pi"
    else "codex";
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
      "opencode/plugins/workmux-status.ts".source = "${workmux}/opencode/plugins/workmux-status.ts";
      "opencode/package.json".source = "${workmux}/opencode/package.json";
    };
    modules.ai.skills = {
      coordinator = "${workmux}/skills/coordinator/";
      merge = "${workmux}/skills/merge/";
      open-pr = "${workmux}/skills/open-pr/";
      rebase = "${workmux}/skills/rebase/";
      workmux = "${workmux}/skills/workmux/";
      worktree = "${workmux}/skills/worktree/";
    };

    xdg.configFile."workmux/config.yaml".source = yaml.generate "workmux-config.yaml" {
      merge_strategy = "rebase";
      nerdfont = true;
      theme = "dark";
      mode = "window";
      worktree_dir = "";
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
