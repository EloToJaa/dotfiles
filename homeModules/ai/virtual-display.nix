{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.modules.ai.virtual-display;
  display = ":${toString cfg.displayNumber}";
  resolution = "${toString cfg.width}x${toString cfg.height}x24";
  vnc_target = "127.0.0.1:${toString cfg.vnc.port}";
  display_requires = {
    Requires = ["xvfb.service"];
    After = ["xvfb.service"];
    PartOf = ["xvfb.service"];
  };
in {
  options.modules.ai.virtual-display = {
    enable = lib.mkEnableOption "Headless X11 desktop (Xvfb + openbox) so agents can run and test desktop apps";
    displayNumber = lib.mkOption {
      type = lib.types.int;
      default = 99;
      description = "X display number.";
    };
    width = lib.mkOption {
      type = lib.types.int;
      default = 1920;
      description = "Screen width in pixels.";
    };
    height = lib.mkOption {
      type = lib.types.int;
      default = 1080;
      description = "Screen height in pixels.";
    };
    vnc = {
      enable = lib.mkEnableOption "x11vnc plus a noVNC web client so the desktop can be used from a browser";
      port = lib.mkOption {
        type = lib.types.port;
        default = 5999;
        description = "VNC port, bound to 127.0.0.1 only.";
      };
      webPort = lib.mkOption {
        type = lib.types.port;
        default = 6080;
        description = "noVNC (websockify) HTTP port, bound to 127.0.0.1 only.";
      };
      passwordFile = lib.mkOption {
        type = lib.types.nullOr lib.types.path;
        default = null;
        description = "Password file in x11vnc `-storepasswd` format. When null, VNC has no password and must only be reachable through a trusted tunnel.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    # Tools agents use to drive and inspect the display
    home.packages = with pkgs; [
      xdotool
      xclip
      scrot
      xorg.xwininfo
      xorg.xprop
    ];

    home.sessionVariables.DISPLAY = display;

    systemd.user.services = {
      # Agents started by the T3 Code backend inherit the display
      t3code.Service.Environment = ["DISPLAY=${display}"];

      xvfb = {
        Unit.Description = "Virtual X11 framebuffer (${display})";
        Service = {
          ExecStart = "${pkgs.xorg.xvfb}/bin/Xvfb ${display} -screen 0 ${resolution} -nolisten tcp";
          Restart = "always";
          RestartSec = 2;
        };
        Install.WantedBy = ["default.target"];
      };

      openbox = {
        Unit = {Description = "Openbox window manager on ${display}";} // display_requires;
        Service = {
          Environment = ["DISPLAY=${display}"];
          ExecStart = lib.getExe pkgs.openbox;
          Restart = "always";
          RestartSec = 2;
        };
        Install.WantedBy = ["default.target"];
      };

      x11vnc = lib.mkIf cfg.vnc.enable {
        Unit = {Description = "VNC server for ${display}";} // display_requires;
        Service = {
          ExecStart = lib.escapeShellArgs (
            [
              (lib.getExe pkgs.x11vnc)
              "-display"
              display
              "-localhost"
              "-rfbport"
              (toString cfg.vnc.port)
              "-forever"
              "-shared"
              "-noxdamage"
            ]
            ++ (
              if cfg.vnc.passwordFile == null
              then ["-nopw"]
              else ["-rfbauth" (toString cfg.vnc.passwordFile)]
            )
          );
          Restart = "always";
          RestartSec = 2;
        };
        Install.WantedBy = ["default.target"];
      };

      novnc = lib.mkIf cfg.vnc.enable {
        Unit = {Description = "noVNC web client for ${display}";} // display_requires;
        Service = {
          ExecStart = lib.escapeShellArgs [
            "${pkgs.python3Packages.websockify}/bin/websockify"
            "--web"
            "${pkgs.novnc}/share/webapps/novnc"
            "127.0.0.1:${toString cfg.vnc.webPort}"
            vnc_target
          ];
          Restart = "always";
          RestartSec = 2;
        };
        Install.WantedBy = ["default.target"];
      };
    };
  };
}
