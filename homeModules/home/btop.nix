{
  pkgs,
  config,
  lib,
  settings,
  ...
}: let
  inherit (settings) catppuccin;
  cfg = config.modules.home.btop;
in {
  options.modules.home.btop = {
    enable = lib.mkEnableOption "Enable btop";
  };
  config = lib.mkIf cfg.enable {
    programs.btop = {
      enable = true;
      package = pkgs.writeShellScriptBin "btop" ''
        exec /run/wrappers/bin/btop "$@"
      '';
      settings = {
        theme_background = false;
        update_ms = 500;
        rounded_corners = false;
        vim_keys = true;
        proc_tree = true;
        proc_sorting = "memory";
        shown_boxes = "cpu mem net proc gpu0";
      };
    };
    catppuccin.btop = {
      enable = true;
      inherit (catppuccin) flavor;
    };
  };
}
