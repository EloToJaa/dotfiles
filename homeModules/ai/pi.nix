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
      pkgs.llm-agents.pi
    ];
    home.file = {
      ".pi/agent" = {
        recursive = true;
        source = ./pi;
      };
      ".pi/agent/AGENTS.md".source = ./AGENTS.md;
      ".pi/agent/extensions/air".source = "${extensions}/air";
      ".pi/agent/extensions/direnv".source = "${extensions}/direnv";
      ".pi/agent/extensions/fetch".source = "${extensions}/fetch";
      ".pi/agent/extensions/notify".source = "${extensions}/notify";
      ".pi/agent/extensions/permission-gate".source = "${extensions}/permission-gate";
      ".pi/agent/extensions/questionnaire".source = "${extensions}/questionnaire";
      ".pi/agent/extensions/slow-mode".source = "${extensions}/slow-mode";
      ".pi/agent/extensions/stash".source = "${extensions}/stash";
      ".pi/agent/extensions/statusline".source = "${extensions}/statusline";
      ".pi/agent/extensions/pi-vim".source = pi-vim;
    };
  };
}
