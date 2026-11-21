{
  lib,
  config,
  pkgs,
  inputs,
  ...
}: let
  cfg = config.modules.desktop.noctalia-shell;
  # sdbus-cpp 2.2.1 only matches async reply callbacks taking std::optional<sdbus::Error>
  # by value; upstream's wpa_supplicant BSS callback takes it by const reference.
  noctaliaPackage = inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default.overrideAttrs (old: {
    postPatch =
      (old.postPatch or "")
      + ''
        substituteInPlace src/dbus/network/wpa_supplicant_service.cpp \
          --replace-fail "[this](const std::optional<sdbus::Error>& error, const sdbus::Variant& value)" \
            "[this](std::optional<sdbus::Error> error, const sdbus::Variant& value)"
      '';
  });
  btop_popup = "exec ghostty --class=com.elotoja.btop-popup --title=btop -e btop";
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
        # Right click opens btop in a floating terminal (floated by a window rule in umbriel.nix)
        widget = {
          cpu.actions.right = btop_popup;
          ram.actions.right = btop_popup;
        };
      };
    };

    # Monitor layout panel; it only supports Umbriel
    programs.noctalia-monitors = {
      enable = lib.mkDefault config.modules.desktop.umbriel.enable;
      layoutFiles = ["umbriel"];
    };
  };
}
