{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.modules.dev.rbw;
in {
  options.modules.dev.rbw = {
    enable = lib.mkEnableOption "Enable bitwarden CLI";
  };

  config = lib.mkIf cfg.enable {
    programs.rbw = {
      enable = true;
      package = pkgs.unstable.rbw;
      settings = {
        email = "lukaszbudziak122@gmail.com";
        base_url = "https://pwd.server.elotoja.com";
        pinentry = pkgs.unstable.pinentry-gnome3;
      };
    };
  };
}
