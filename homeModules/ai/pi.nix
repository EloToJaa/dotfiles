{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.modules.ai.pi;
  extensions = pkgs.callPackage ./pkgs/pi-agent-extensions.nix {};
  pi-vim = pkgs.callPackage ./pkgs/pi-vim.nix {};
in {
  options.modules.ai.pi = {
    enable = lib.mkEnableOption "Enable pi module";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [
      pkgs.llm-agents.omp
    ];
    programs.zsh.shellAliases = {
      pi = "omp";
    };
    home.file = {
      ".omp/agent" = {
        recursive = true;
        source = ./pi;
      };
      ".omp/agent/AGENTS.md".source = ./AGENTS.md;
      ".omp/agent/extensions/air".source = "${extensions}/air";
      ".omp/agent/extensions/direnv".source = "${extensions}/direnv";
      # ".omp/agent/extensions/fetch".source = "${extensions}/fetch";
      ".omp/agent/extensions/notify".source = "${extensions}/notify";
      # ".omp/agent/extensions/permission-gate".source = "${extensions}/permission-gate";
      # ".omp/agent/extensions/questionnaire".source = "${extensions}/questionnaire";
      # ".omp/agent/extensions/slow-mode".source = "${extensions}/slow-mode";
      ".omp/agent/extensions/stash".source = "${extensions}/stash";
      # ".omp/agent/extensions/statusline".source = "${extensions}/statusline";
      ".omp/agent/extensions/pi-vim".source = pi-vim;
    };
  };
}
