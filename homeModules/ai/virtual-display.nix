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
  # Environment every process on the display needs; apps must also opt in to AT-SPI
  session_env =
    {
      DISPLAY = display;
      XDG_SESSION_TYPE = "x11";
    }
    // lib.optionalAttrs cfg.accessibility.enable {
      GTK_A11Y = "atspi";
      QT_LINUX_ACCESSIBILITY_ALWAYS_ON = "1";
    };
  env_list = lib.mapAttrsToList (name: value: "${name}=${value}") session_env;
  mcp_env = session_env // {COMPUTER_USE_LINUX_INDICATOR = "0";}; # the overlay only exists on GNOME
  mcp_exe = lib.getExe pkgs.computer-use-linux;
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
    accessibility.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Run the AT-SPI accessibility bus and registry so agents can read apps' widget trees
        instead of guessing pixel coordinates. GTK and Qt apps started from the display opt in
        through the exported environment; Chromium and Electron apps need
        `--force-renderer-accessibility`.
      '';
    };
    mcp.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Install `computer-use-linux` (screenshots, AT-SPI trees, window targeting and input over MCP)
        and register it as the `desktop` MCP server in the enabled agents
        (Claude Code, Codex and opencode).
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    # Tools agents use to drive and inspect the display
    home.packages = with pkgs;
      [
        xdotool
        xclip
        scrot
        wmctrl
        xorg.xwininfo
        xorg.xprop
      ]
      ++ lib.optional cfg.mcp.enable computer-use-linux;

    home.sessionVariables = session_env;

    # One `desktop` server for every enabled agent; they inherit nothing from a login session
    programs = lib.mkIf cfg.mcp.enable {
      claude-code.mcpServers.desktop = lib.mkIf config.programs.claude-code.enable {
        command = mcp_exe;
        args = ["mcp"];
        env = mcp_env;
      };
      codex.settings.mcp_servers.desktop = lib.mkIf config.programs.codex.enable {
        command = mcp_exe;
        args = ["mcp"];
        env = mcp_env;
      };
      opencode.settings.mcp.desktop = lib.mkIf config.programs.opencode.enable {
        type = "local";
        command = [mcp_exe "mcp"];
        environment = mcp_env;
        enabled = true;
      };
    };

    systemd.user.services = {
      # Agents started by the T3 Code backend inherit the display
      t3code.Service.Environment = env_list;

      at-spi-bus = lib.mkIf cfg.accessibility.enable {
        Unit = {Description = "AT-SPI accessibility bus for ${display}";} // display_requires;
        Service = {
          Environment = ["DISPLAY=${display}"];
          ExecStart = "${pkgs.at-spi2-core}/libexec/at-spi-bus-launcher --launch-immediately";
          Restart = "always";
          RestartSec = 2;
        };
        Install.WantedBy = ["default.target"];
      };

      at-spi-registry = lib.mkIf cfg.accessibility.enable {
        Unit = {
          Description = "AT-SPI registry for ${display}";
          Requires = ["at-spi-bus.service"];
          After = ["at-spi-bus.service"];
          PartOf = ["xvfb.service"];
        };
        Service = {
          Environment = ["DISPLAY=${display}"];
          ExecStart = "${pkgs.at-spi2-core}/libexec/at-spi2-registryd --use-gnome-session";
          Restart = "always";
          RestartSec = 2;
        };
        Install.WantedBy = ["default.target"];
      };

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
