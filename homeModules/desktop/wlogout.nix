{
  pkgs,
  config,
  lib,
  settings,
  ...
}: let
  inherit (settings) username isLaptop;
  cfg = config.modules.desktop.wlogout;
in {
  options.modules.desktop.wlogout = {
    enable = lib.mkEnableOption "Enable wlogout";
  };
  config = lib.mkIf cfg.enable {
    catppuccin.wlogout.enable = false;
    programs.wlogout = let
      inherit (pkgs) systemd;
      hyprlock = config.programs.hyprlock.package;
      package = pkgs.unstable.wlogout;
      bgImageSection = name: ''
        #${name} {
          background-image: image(url("${package}/share/wlogout/icons/${name}.png"));
        }
      '';
    in {
      inherit package;
      enable = true;
      layout = [
        {
          label = "shutdown";
          action = "${systemd}/bin/systemctl poweroff";
          text = "Shutdown";
          keybind = "s";
        }
        {
          label = "reboot";
          action = "${systemd}/bin/systemctl reboot";
          text = "Reboot";
          keybind = "r";
        }
        {
          label = "logout";
          action = "${systemd}/bin/loginctl terminate-user ${username}";
          text = "Logout";
          keybind = "e";
        }
        {
          label = "lock";
          action = "${hyprlock}/bin/hyprlock";
          text = "Lock";
          keybind = "l";
        }
        {
          label = "hibernate";
          action = "${systemd}/bin/systemctl hibernate";
          text = "Hibernate";
          keybind = "h";
        }
        {
          label = "suspend";
          action = "${systemd}/bin/systemctl suspend";
          text = "Suspend";
          keybind = "u";
        }
      ];

      style =
        /*
        css
        */
        ''
          * {
            background: none;
          }

          window {
          	background-color: rgba(0, 0, 0, .5);
          }

          button {
            background: rgba(0, 0, 0, .05);
            border-radius: 8px;
            box-shadow: inset 0 0 0 1px rgba(255, 255, 255, .1), 0 0 rgba(0, 0, 0, .5);
            margin: 1rem;
            background-repeat: no-repeat;
            background-position: center;
            background-size: ${
            if isLaptop
            then "30"
            else "25"
          }%;
          }

          button:focus, button:active, button:hover {
            background-color: rgba(255, 255, 255, 0.2);
            outline-style: none;
          }

          ${lib.concatMapStringsSep "\n" bgImageSection [
            "lock"
            "logout"
            "suspend"
            "hibernate"
            "shutdown"
            "reboot"
          ]}
        '';
    };
  };
}
