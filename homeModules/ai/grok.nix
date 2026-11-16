{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.modules.ai.grok;
in {
  options.modules.ai.grok.enable = lib.mkEnableOption "Enable Grok CLI module";

  config = lib.mkIf cfg.enable {
    home.packages = [pkgs.llm-agents.grok];
  };
}
