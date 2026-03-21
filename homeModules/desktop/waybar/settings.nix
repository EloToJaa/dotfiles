{
  host,
  config,
  lib,
  settings,
  ...
}: let
  inherit (settings) terminal;
  custom = {
    font = "JetBrainsMono Nerd Font";
    font_size = "18px";
    font_weight = "bold";
    #   text_color = "#FBF1C7";
    text_color = "#cdd6f4";
    #   background_0 = "#1D2021";
    background_0 = "#181825";
    #   background_1 = "#282828";
    background_1 = "#11111B";
    #   border_color = "#928374";
    border_color = "#fab387";
    red = "#f38ba8";
    green = "#a6e3a1";
    yellow = "#f9e2af";
    blue = "#89b4fa";
    magenta = "#cba6f7";
    cyant = "#94e2d5";
    orange = "#fab387";
    opacity = "1";
    indicator_height = "2px";
  };
  launchProgram =
    if (terminal == "wezterm")
    then "wezterm start --"
    else "ghostty -e";
  cfg = config.modules.desktop.waybar;
in {
  config = lib.mkIf cfg.enable {
    programs.waybar.settings.mainBar = with custom; {
      position = "bottom";
      layer = "top";
      height = 28;
      margin-top = 0;
      margin-bottom = 0;
      margin-left = 0;
      margin-right = 0;
      modules-left = [
        "custom/launcher"
        "hyprland/workspaces"
        "tray"
      ];
      modules-center = [
        "clock"
      ];
      modules-right = [
        "cpu"
        "memory"
        (
          if (host == "desktop")
          then "disk"
          else ""
        )
        "pulseaudio"
        "network"
        "battery"
        "custom/notification"
      ];
      clock = {
        calendar = {
          format = {today = "<span color='${green}'><b>{}</b></span>";};
        };
        format = "  {:%H:%M %d/%m}";
        tooltip = "true";
        tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
        # format-alt= "  {:%d/%m}";
      };
      "hyprland/workspaces" = {
        active-only = false;
        disable-scroll = true;
        format = "{icon}";
        on-click = "activate";
        format-icons = {
          sort-by-number = true;
        };
        persistent-workspaces = {
          "1" = [];
          "2" = [];
          "3" = [];
          "4" = [];
          "5" = [];
          "6" = [];
        };
      };
      cpu = {
        format = "<span foreground='${green}'> </span> {usage}%";
        format-alt = "<span foreground='${green}'> </span> {avg_frequency} GHz";
        interval = 2;
        on-click-right = "hyprctl dispatch exec '[float; center; size 950 650] ${launchProgram} btop'";
      };
      memory = {
        format = "<span foreground='${cyant}'>󰟜 </span>{}%";
        format-alt = "<span foreground='${cyant}'>󰟜 </span>{used} GiB"; # 
        interval = 2;
        on-click-right = "hyprctl dispatch exec '[float; center; size 950 650] ${launchProgram} btop'";
      };
      disk = {
        # path = "/";
        format = "<span foreground='${orange}'>󰋊 </span>{percentage_used}%";
        interval = 60;
        on-click-right = "hyprctl dispatch exec '[float; center; size 950 650] ${launchProgram} btop'";
      };
      network = {
        format-wifi = "<span foreground='${magenta}'> </span> {signalStrength}%";
        format-ethernet = "<span foreground='${magenta}'>󰀂 </span>";
        tooltip-format = "Connected to {essid} {ifname} via {gwaddr}";
        format-linked = "{ifname} (No IP)";
        format-disconnected = "<span foreground='${magenta}'>󰖪 </span>";
      };
      tray = {
        icon-size = 20;
        spacing = 8;
      };
      pulseaudio = {
        format = "{icon} {volume}%";
        format-muted = "<span foreground='${blue}'> </span> {volume}%";
        format-icons = {
          default = ["<span foreground='${blue}'> </span>"];
        };
        scroll-step = 5;
        on-click = "pamixer -t";
        on-click-right = "pavucontrol";
      };
      battery = {
        format = "<span foreground='${yellow}'>{icon}</span> {capacity}%";
        format-icons = [" " " " " " " " " "];
        format-charging = "<span foreground='${yellow}'> </span>{capacity}%";
        format-full = "<span foreground='${yellow}'> </span>{capacity}%";
        format-warning = "<span foreground='${yellow}'> </span>{capacity}%";
        interval = 5;
        states = {
          warning = 20;
        };
        format-time = "{H}h{M}m";
        tooltip = true;
        tooltip-format = "{time}";
      };
      "custom/launcher" = {
        format = "";
        on-click = "uwsm app -- vicinae vicinae://toggle";
        on-click-right = "hyprctl dispatch exec '[float; size 925 615] waypaper";
        tooltip = "false";
      };
      "custom/notification" = {
        tooltip = false;
        format = "{icon} ";
        format-icons = {
          notification = "<span foreground='red'><sup></sup></span>  <span foreground='${red}'></span>";
          none = "  <span foreground='${red}'></span>";
          dnd-notification = "<span foreground='red'><sup></sup></span>  <span foreground='${red}'></span>";
          dnd-none = "  <span foreground='${red}'></span>";
          inhibited-notification = "<span foreground='red'><sup></sup></span>  <span foreground='${red}'></span>";
          inhibited-none = "  <span foreground='${red}'></span>";
          dnd-inhibited-notification = "<span foreground='red'><sup></sup></span>  <span foreground='${red}'></span>";
          dnd-inhibited-none = "  <span foreground='${red}'></span>";
        };
        return-type = "json";
        exec-if = "which swaync-client";
        exec = "swaync-client -swb";
        on-click = "swaync-client -t -sw";
        on-click-right = "swaync-client -d -sw";
        escape = true;
      };
    };
  };
}
