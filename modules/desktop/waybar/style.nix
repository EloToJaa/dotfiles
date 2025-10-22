{
  config,
  lib,
  ...
}: let
  custom = {
    font = "JetBrainsMono Nerd Font";
    font_size = "18px";
    font_weight = "bold";
    text_color = "#cdd6f4";
    background_0 = "#181825";
    background_1 = "#11111B";
    border_color = "#fab387";
    workspace = "#f38ba8";
    active_workspace = "#fab387";
    opacity = "1";
    indicator_height = "2px";
  };
  cfg = config.modules.desktop.waybar;
in {
  config = lib.mkIf cfg.enable {
    programs.waybar.style = with custom;
    /*
    css
    */
      ''
        * {
          border: none;
          border-radius: 0px;
          padding: 0;
          margin: 0;
          font-family: ${font};
          font-weight: ${font_weight};
          opacity: ${opacity};
          font-size: ${font_size};
        }

        window#waybar {
          background: ${background_1};
          border-top: 1px solid #928374;
        }

        tooltip {
          background: ${background_0};
          border: 1px solid ${border_color};
        }
        tooltip label {
          margin: 5px;
          color: ${text_color};
        }

        #workspaces {
          padding-left: 15px;
        }
        #workspaces button {
          color: ${workspace};
          padding-left:  5px;
          padding-right: 5px;
          margin-right: 10px;
        }
        #workspaces button.empty {
          color: ${text_color};
        }
        #workspaces button.active {
          color: ${active_workspace};
        }

        #clock {
          color: ${text_color};
        }

        #tray {
          margin-left: 10px;
          color: ${text_color};
        }
        #tray menu {
          background: ${background_1};
          border: 1px solid ${border_color};
          padding: 8px;
        }
        #tray menuitem {
          padding: 1px;
        }

        #pulseaudio, #network, #cpu, #memory, #disk, #battery, #custom-notification {
          padding-left: 5px;
          padding-right: 5px;
          margin-right: 10px;
          color: ${text_color};
        }

        #pulseaudio {
          margin-left: 15px;
        }

        #custom-notification {
          margin-left: 15px;
          padding-right: 2px;
          margin-right: 5px;
        }

        #custom-launcher {
          font-size: 20px;
          color: ${text_color};
          font-weight: bold;
          margin-left: 15px;
          padding-right: 10px;
        }
      '';
  };
}
