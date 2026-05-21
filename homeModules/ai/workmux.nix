{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.modules.ai.workmux;
  workmux = pkgs.callPackage ./pkgs/workmux-skills.nix {};
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
    programs.opencode.skills = {
      coordinator = "${workmux}/skills/coordinator/";
      merge = "${workmux}/skills/merge/";
      open-pr = "${workmux}/skills/open-pr/";
      rebase = "${workmux}/skills/rebase/";
      workmux = "${workmux}/skills/workmux/";
      worktree = "${workmux}/skills/worktree/";
    };
    home.file = {
      ".pi/agent/skills/coordinator".source = "${workmux}/skills/coordinator/";
      ".pi/agent/skills/merge".source = "${workmux}/skills/merge/";
      ".pi/agent/skills/open-pr".source = "${workmux}/skills/open-pr/";
      ".pi/agent/skills/rebase".source = "${workmux}/skills/rebase/";
      ".pi/agent/skills/workmux".source = "${workmux}/skills/workmux/";
      ".pi/agent/skills/worktree".source = "${workmux}/skills/worktree/";
    };

    xdg.configFile."workmux/config.yaml".text =
      /*
      yaml
      */
      ''
        merge_strategy: rebase
        nerdfont: true
        theme: dark
        mode: window
        worktree_dir: ""
        panes:
          - command: nvim
          - command: pi
            split: horizontal
            focus: true
          - split: vertical
        status_icons:
          working: "🤖" # Agent is processing
          waiting: "💬" # Agent needs input (auto-clears on focus)
          done: "✅" # Agent finished (auto-clears on focus)
      '';
  };
}
