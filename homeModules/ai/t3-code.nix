{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.modules.ai.t3-code;
in {
  options.modules.ai.t3-code = {
    enable = lib.mkEnableOption "Enable T3 Code module";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [pkgs.llm-agents.t3code-desktop];
    programs.t3code = {
      enable = true;
      package = pkgs.llm-agents.t3code;
    };
  };
}
