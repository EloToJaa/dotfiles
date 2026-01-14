{
  pkgs,
  lib,
  config,
  ...
}: let
  inherit (config.settings) isServer;
  cfg = config.modules.home.fastfetch;
in {
  options.modules.home.fastfetch = {
    enable = lib.mkEnableOption "Enable fastfetch";
  };
  config = lib.mkIf cfg.enable {
    programs.fastfetch = {
      enable = true;
      package = pkgs.unstable.fastfetch;
      settings = {
        logo = {
          source = "${../../.github/assets/logo/nixos-logo.png}";
          type = "kitty-icat";
          width = 33;
          padding = {
            top = 2;
          };
        };
        display = {
          separator = " 󰑃  ";
        };
        modules =
          [
            "break"
            {
              type = "title";
              color = {
                user = "35";
                host = "36";
              };
            }
            {
              type = "separator";
              string = "▔";
            }
            {
              type = "os";
              key = " Distro";
              keyColor = "yellow";
            }
            {
              type = "kernel";
              key = "  ├─";
              keyColor = "yellow";
            }
            {
              type = "packages";
              key = "  ├─󰏖";
              keyColor = "yellow";
            }
            {
              type = "shell";
              key = "  └─";
              keyColor = "yellow";
            }
            "break"
          ]
          ++ lib.optionals (!isServer)
          [
            {
              type = "wm";
              key = " DE/WM";
              keyColor = "blue";
            }
            {
              type = "theme";
              key = "  ├─󰉼";
              keyColor = "blue";
            }
            {
              type = "wmtheme";
              key = "  ├─󰉼";
              keyColor = "blue";
            }
            {
              type = "icons";
              key = "  ├─󰉋";
              keyColor = "blue";
            }
            {
              type = "cursor";
              key = "  ├─󰳽";
              keyColor = "blue";
            }
            {
              type = "font";
              key = "  ├─";
              format = "{2}";
              keyColor = "blue";
            }
            {
              type = "terminal";
              key = "  └─";
              keyColor = "blue";
            }
            "break"
          ]
          ++ [
            {
              type = "host";
              key = "󰌢 System";
              keyColor = "green";
            }
            {
              type = "board";
              key = "󰌢 System";
              keyColor = "green";
              condition = {
                succeeded = false;
              };
            }
            {
              type = "display";
              key = "  ├─󰹑";
              keyColor = "green";
              compactType = "original-with-refresh-rate";
            }
            {
              type = "cpu";
              key = "  ├─";
              keyColor = "green";
            }
            {
              type = "gpu";
              key = "  ├─";
              format = "{2}";
              keyColor = "green";
            }
            {
              type = "memory";
              key = "  ├─󰘚";
              keyColor = "green";
            }
            {
              type = "disk";
              key = "  ├─󰋊";
              folders = "/";
              keyColor = "green";
            }
            {
              type = "uptime";
              key = "  └─󰔚";
              keyColor = "green";
            }
            "break"
            {
              type = "colors";
              symbol = "background";
              paddingLeft = 9;
            }
            "break"
          ];
      };
    };
  };
}
