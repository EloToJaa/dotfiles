{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (config.settings) uid username;
  cfg = config.modules.core.wayland;
  avatar = ../assets/avatar.png;
  # Compositors stay selectable in the greeter; this only picks the preselected one.
  defaultSession =
    if cfg.umbriel.enable
    then "umbriel"
    else "niri";
in {
  config = lib.mkIf (config.modules.core.enable && cfg.enable) {
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
      accounts-daemon.enable = true;
      greetd = {
        enable = true;
        settings = {
          terminal.vt = 1;
          default_session.user = username;
        };
      };
    };

    services.displayManager.noctalia-greeter = {
      enable = true;
      # Lets the shell's "Sync Greeter" copy wallpaper and palette without a polkit prompt
      passwordless-sync-users = [username];
      settings = {
        session.default = defaultSession;
        user.default = username;
        appearance.theme_mode = "dark";
      };
    };
  };
}
