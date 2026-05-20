{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.modules.dev.ai.pi;
in {
  options.modules.dev.ai.pi = {
    enable = lib.mkEnableOption "Enable pi module";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [
      pkgs.llm-agents.pi
    ];
  };
}
