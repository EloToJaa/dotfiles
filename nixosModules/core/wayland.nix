{
  pkgs,
  lib,
  config,
  inputs,
  ...
}: let
  system = pkgs.stdenv.hostPlatform.system;
  hyprlandPackages = inputs.hyprland.packages.${system};
  hyprlandNixpkgs = inputs.hyprland.inputs.nixpkgs.legacyPackages.${system};
  glaze7 = hyprlandNixpkgs.glaze.overrideAttrs (_: {
    version = "7.2.0";
    src = hyprlandNixpkgs.fetchFromGitHub {
      owner = "stephenberry";
      repo = "glaze";
      rev = "v7.2.0";
      hash = "sha256-f3NVRi3SXKo42hn0WCw7JsOK3EkdOVJIcuzhPorKjFY=";
    };
  });
  hyprland = hyprlandPackages.hyprland.override {
    "glaze-hyprland" = glaze7.override {enableSSL = false;};
  };
  inherit (hyprlandPackages) xdg-desktop-portal-hyprland;
  inherit (config.settings) uid username;
  avatar = ./assets/avatar.png;
  niri = pkgs.unstable.niri;
  cfg = config.modules.core.wayland;
in {
  options.modules.core.wayland = {
    enable = lib.mkEnableOption "Enable wayland module";
    hyprland.enable = lib.mkEnableOption "Enable hyprland";
    niri.enable = lib.mkEnableOption "Enable niri";
  };
  config = lib.mkIf cfg.enable {
    environment.pathsToLink = ["/share/applications" "/share/xdg-desktop-portal"];

    programs = {
      hyprland = lib.mkIf cfg.hyprland.enable {
        enable = true;
        package = hyprland;
        portalPackage = xdg-desktop-portal-hyprland;
        withUWSM = false;
        xwayland.enable = true;
      };
      niri = lib.mkIf cfg.niri.enable {
        enable = true;
        package = niri;
        useNautilus = true;
        withUWSM = false;
        withXDG = true;
      };
    };
    systemd.user.services.niri-flake-polkit.enable = lib.mkIf cfg.niri.enable false;

    systemd.services.set-user-avatar = {
      description = "Set ${username}'s AccountsService avatar";
      wantedBy = ["multi-user.target"];
      after = ["accounts-daemon.service"];
      requires = ["accounts-daemon.service"];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${pkgs.systemd}/bin/busctl call org.freedesktop.Accounts /org/freedesktop/Accounts/User${toString uid} org.freedesktop.Accounts.User SetIconFile s ${avatar}";
      };
    };

    services = {
      xserver.displayManager.lightdm.enable = false;
      dbus.implementation = "broker";
      accounts-daemon.enable = true;
      power-profiles-daemon.enable = true;
      greetd = {
        enable = true;

        settings = {
          terminal.vt = 1;
          default_session.user = username;
        };
      };
    };
    programs.dms-greeter = {
      enable = true;
      compositor = {
        name =
          if cfg.hyprland.enable
          then "hyprland"
          else "niri";
        package = lib.mkIf cfg.hyprland.enable hyprland;
        customConfig = lib.optionalString (cfg.niri.enable && !cfg.hyprland.enable) ''
          hotkey-overlay {
            skip-at-startup
          }

          environment {
            DMS_RUN_GREETER "1"
          }
        '';
      };
      # Sync your user's DankMaterialShell theme with the greeter. You'll probably want this
      configHome = "/home/${username}";

      # Save the logs to a file
      logs = {
        save = true;
        path = "/tmp/dms-greeter.log";
      };

      # Custom Quickshell Package
      quickshell.package = pkgs.unstable.quickshell;
    };

    boot.initrd.kernelModules = ["amdgpu"];
  };
}
