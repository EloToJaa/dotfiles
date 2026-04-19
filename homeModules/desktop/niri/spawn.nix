{
  config,
  lib,
  settings,
  ...
}: let
  cfg = config.modules.desktop.niri;
  inherit (settings) discord;
in {
  config = lib.mkIf cfg.enable {
    programs.niri.settings.spawn-at-startup = [
      # System tray apps
      # {command = ["poweralertd"];}
      # {command = ["wl-clip-persist" "--clipboard" "both"];}
      {command = ["udiskie" "--automount" "--notify" "--smart-tray"];}
      {command = [discord];}
      {command = ["opencloud"];}
    ];
  };
}
