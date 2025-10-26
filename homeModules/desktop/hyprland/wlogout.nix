{
  pkgs,
  config,
  lib,
  ...
}: let
  inherit (config.settings) catppuccin;
  cfg = config.modules.desktop.wlogout;
in {
  options.modules.desktop.wlogout = {
    enable = lib.mkEnableOption "Enable wlogout";
  };
  config = lib.mkIf cfg.enable {
    catppuccin.wlogout = {
      inherit (catppuccin) flavor accent;
      enable = true;
      iconStyle = "wlogout";
    };
    programs.wlogout = {
      enable = true;
      package = pkgs.unstable.wlogout;
      layout = [
        {
          label = "lock";
          action = "hyprlock";
          text = "Lock";
          keybind = "l";
        }
        {
          label = "hibernate";
          action = "systemctl hibernate";
          text = "Hibernate";
          keybind = "h";
        }
        {
          label = "logout";
          action = "loginctl terminate-user $USER";
          text = "Logout";
          keybind = "e";
        }
        {
          label = "shutdown";
          action = "systemctl poweroff";
          text = "Shutdown";
          keybind = "s";
        }
        {
          label = "suspend";
          action = "systemctl suspend";
          text = "Suspend";
          keybind = "u";
        }
        {
          label = "reboot";
          action = "systemctl reboot";
          text = "Reboot";
          keybind = "r";
        }
      ];
    };
  };
}
