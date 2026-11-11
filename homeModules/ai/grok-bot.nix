{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.modules.ai.grok-bot;
in {
  options.modules.ai.grok-bot.enable = lib.mkEnableOption "Enable Grok Bot module";

  config = lib.mkIf cfg.enable {
    home.packages = [pkgs.llm-agents.grok-bot];
  };
}
