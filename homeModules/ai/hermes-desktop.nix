{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.modules.ai.hermes-desktop;
in {
  options.modules.ai.hermes-desktop.enable = lib.mkEnableOption "Enable Hermes Desktop module";

  config = lib.mkIf cfg.enable {
    home.packages = [pkgs.llm-agents.hermes-desktop];
  };
}
