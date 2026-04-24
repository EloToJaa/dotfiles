{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.modules.dev.ai.btca;
in {
  options.modules.dev.ai.btca = {
    enable = lib.mkEnableOption "Enable btca module";
  };
  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      btca
    ];
    programs.opencode.skills = {
      better-context = "${pkgs.btca}/skills/btca-cli/";
    };
  };
}
