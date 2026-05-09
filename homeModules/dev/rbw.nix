{
  pkgs,
  lib,
  config,
  settings,
  ...
}: let
  inherit (settings) email;
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
        inherit email;
        base_url = "https://pwd.server.elotoja.com";
        pinentry = pkgs.unstable.pinentry-gnome3;
      };
    };
  };
}
