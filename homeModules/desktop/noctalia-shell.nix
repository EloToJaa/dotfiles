{
  lib,
  config,
  pkgs,
  inputs,
  ...
}: let
  cfg = config.modules.desktop.noctalia-shell;
  noctaliaPackage = inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default;
in {
  options.modules.desktop.noctalia-shell = {
    enable = lib.mkEnableOption "Enable Noctalia shell";
  };
  config = lib.mkIf cfg.enable {
    programs.noctalia = {
      enable = true;
      package = noctaliaPackage;
      systemd.enable = true;

      settings = {
        shell = {
          font_family = "JetBrainsMonoNL Nerd Font";
          telemetry_enabled = false;
          clipboard_enabled = true;
          clipboard_history_max_entries = 25;
        };
        theme = {
          mode = "dark";
          source = "community";
          community_palette = "Catppuccin Mocha Blue";
        };
        shell.animation.speed = 1.5;
        bar.main = {
          position = "bottom";
          thickness = 42;
          widget_spacing = 10;
          capsule = true;
          capsule_fill = "surface_container";
          capsule_opacity = 0.9;
          capsule_padding = 8.0;
          capsule_border_width = 0.0;
          margin_ends = 0;
          margin_edge = 0;
          margin_opposite_edge = 0;
          radius = 0;
          radius_top_left = 0;
          radius_top_right = 0;
          radius_bottom_left = 0;
          radius_bottom_right = 0;
          concave_edge_corners = false;
          start = ["workspaces"];
          center = ["media" "clock" "weather"];
          end = ["cpu" "ram" "tray" "notifications" "battery" "network" "bluetooth" "volume" "session"];
        };
      };
    };

    # Monitor layout panel; it only supports Umbriel
    programs.noctalia-monitors = {
      enable = lib.mkDefault config.modules.desktop.umbriel.enable;
      layoutFiles = ["umbriel"];
    };

    # Niri integration recommended by https://docs.noctalia.dev/noctalia/compositor-settings/niri/
    wayland.windowManager.niri.settings = lib.mkIf config.modules.desktop.niri.enable {
      _children = [
        {
          window-rule = {
            match._props.app-id = "^dev\\.noctalia\\.Noctalia$";
            open-floating = true;
            default-column-width.fixed = 1080;
            default-window-height.fixed = 920;
          };
        }
        {
          layer-rule = {
            match._props.namespace = "^noctalia-backdrop";
            place-within-backdrop = true;
          };
        }
      ];
      # Lets notification actions activate their window
      debug.honor-xdg-activation-with-invalid-serial = [];
    };
  };
}
