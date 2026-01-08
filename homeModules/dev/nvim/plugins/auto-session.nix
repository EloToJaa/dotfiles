{
  config,
  lib,
  ...
}: let
  cfg = config.modules.dev.nvim.plugins.auto-session;
in {
  options.modules.dev.nvim.plugins.auto-session = {
    enable = lib.mkEnableOption "Enable auto-session";
  };
  config = lib.mkIf cfg.enable {
    programs.nixvim.plugins.auto-session = {
      enable = true;
      settings = {
        enabled = true;
        auto_restore = true;
        auto_save = true;
        suppressed_dirs = [
          "~/"
          "~/Downloads"
          "~/Documents"
          "~/Desktop"
        ];
      };
    };
  };
}
