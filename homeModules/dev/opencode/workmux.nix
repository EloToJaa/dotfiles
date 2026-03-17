{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  cfg = config.modules.dev.opencode;
  aiTools = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system};
  workmux = pkgs.callPackage ./pkgs/workmux-skills.nix {};
in {
  config = lib.mkIf cfg.enable {
    home.packages = [
      aiTools.workmux
    ];

    programs.zsh.zsh-abbr.abbreviations = {
      wm = "workmux";
    };

    xdg.configFile."opencode/plugins/workmux-status.ts".source = "${workmux}/.opencode/plugin/workmux-status.ts";
    programs.opencode.skills = {
      coordinator = "${workmux}/skills/coordinator/";
      merge = "${workmux}/skills/merge/";
      open-pr = "${workmux}/skills/open-pr/";
      rebase = "${workmux}/skills/rebase/";
      worktree = "${workmux}/skills/worktree/";
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
          - command: nvim -c 'lua require("opencode.cli.server").get()'
          - command: opencode --port $(find-port 5660)
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
