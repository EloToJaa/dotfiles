{
  config,
  inputs,
  lib,
  pkgs,
  ...
}: let
  cfg = config.modules.ai.t3-code;
  t3codePackages = pkgs.unstable.llm-agents;
in {
  options.modules.ai.t3-code = {
    enable = lib.mkEnableOption "Enable T3 Code module";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [
      t3codePackages.t3code-desktop
      pkgs.unstable.nodejs_26 # remote environments
    ];
    programs.t3code = {
      enable = true;
      package = t3codePackages.t3code;
    };
  };
}
