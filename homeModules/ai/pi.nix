{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.modules.ai.pi;
in {
  options.modules.ai.pi = {
    enable = lib.mkEnableOption "Enable pi module";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [
      pkgs.llm-agents.pi
    ];
  };
}
