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

    xdg.configFile."opencode/plugins/workmux-status.ts".source = "${aiTools.workmux}/plugins/workmux-status.ts";
    programs.opencode.skills = {
      coordinator = "${aiTools.workmux}/skills/coordinator/";
      merge = "${aiTools.workmux}/skills/merge/";
      open-pr = "${aiTools.workmux}/skills/open-pr/";
      rebase = "${aiTools.workmux}/skills/rebase/";
      worktree = "${aiTools.workmux}/skills/worktree/";
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
        worktree_dir: <project>__worktrees/
        panes:
          - command: <agent>
            focus: true
          - split: horizontal
      '';
  };
}
