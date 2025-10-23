{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.modules.core.gnome;
in {
  options.modules.core.gnome = {
    enable = lib.mkEnableOption "Enable gnome module";
  };
  config = lib.mkIf cfg.enable {
    programs = {
      seahorse.enable = true;
      dconf.enable = true;
    };

    security.polkit.enable = true;
    services = {
      gnome = {
        gnome-keyring.enable = true;
        tinysparql.enable = true;
      };
      gvfs.enable = true;
      logind.extraConfig = ''
        # don't shutdown when power button is short-pressed
        HandlePowerKey=ignore
      '';

      dbus = {
        enable = true;
        packages = with pkgs.unstable; [
          gcr
          gnome-settings-daemon
        ];
      };
    };
    environment.systemPackages = with pkgs.unstable; [
      ntfs3g
    ];
  };
}
