{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.modules.ai.t3-code;
  t3codePackages = pkgs.unstable.llm-agents;
in {
  options.modules.ai.t3-code = {
    enable = lib.mkEnableOption "Enable T3 Code module";
    desktop.enable = lib.mkEnableOption "Enable T3 Code desktop client";
  };

  config = lib.mkIf cfg.enable {
    home.packages =
      [pkgs.unstable.nodejs_26] # remote environments
      ++ lib.optionals cfg.desktop.enable [t3codePackages.t3code-desktop];
    programs.t3code = {
      enable = true;
      package = t3codePackages.t3code;
    };
  };
}
