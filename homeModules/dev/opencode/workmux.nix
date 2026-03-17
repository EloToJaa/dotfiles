{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  cfg = config.modules.dev.opencode;
  aiTools = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system};
in {
  config = lib.mkIf cfg.enable {
    home.packages = [
      aiTools.workmux
    ];

    programs.zsh.zsh-abbr.abbreviations = {
      wm = "workmux";
    };

    xdg.configFile."opencode/plugins/workmux-status.ts".source = "${pkgs.workmux}/.opencode/plugin/workmux-status.ts";
    programs.opencode.skills = {
      coordinator = "${pkgs.workmux}/skills/coordinator/";
      merge = "${pkgs.workmux}/skills/merge/";
      open-pr = "${pkgs.workmux}/skills/open-pr/";
      rebase = "${pkgs.workmux}/skills/rebase/";
      worktree = "${pkgs.workmux}/skills/worktree/";
    };

    xdg.configFile."workmux/config.yaml".text =
      /*
      yaml
      */
      ''
        merge_strategy: rebase
        agent: opencode
        nerdfont: true
        theme: dark
        mode: window
        worktree_dir: ""
        panes:
          - command: nvim
          - command: <agent>
            split: horizontal
            focus: true
        status_icons:
          working: "🤖" # Agent is processing
          waiting: "💬" # Agent needs input (auto-clears on focus)
          done: "✅" # Agent finished (auto-clears on focus)
      '';
  };
}
