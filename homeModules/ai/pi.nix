{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.modules.ai.pi;
  extensions = pkgs.callPackage ./pkgs/pi-agent-extensions.nix {};
in {
  options.modules.ai.pi = {
    enable = lib.mkEnableOption "Enable pi module";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [
      pkgs.llm-agents.pi
    ];
    home.file.".pi/agent/extensions" = {
      recursive = true;
      source = extensions;
    };
  };
}
