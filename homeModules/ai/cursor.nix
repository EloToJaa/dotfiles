{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.modules.ai.cursor;
in {
  options.modules.ai.cursor.enable = lib.mkEnableOption "Enable Cursor CLI module";

  config = lib.mkIf cfg.enable {
    home.packages = [pkgs.llm-agents.cursor-agent];
  };
}
