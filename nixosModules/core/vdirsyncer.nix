{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.modules.core.vdirsyncer;
  inherit (config.settings) username;
in {
  options.modules.core.vdirsyncer = {
    enable = lib.mkEnableOption "Enable vdirsyncer";
    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.vdirsyncer;
      description = "The vdirsyncer package to use.";
    };
  };

  config = lib.mkIf cfg.enable {
    services.vdirsyncer = {
      inherit (cfg) package;
      enable = true;
      jobs.main = {
        user = username;
        forceDiscover = true;
        config = {
          statusPath = "/home/${username}/.local/share/vdirsyncer/status/";
          storages = {
            local_calendar = {
              type = "filesystem";
              path = "/home/${username}/.local/share/calendars/";
              fileext = ".ics";
            };
            remote_calendar = {
              type = "caldav";
              url = "https://dav.server.elotoja.com/";
            };
          };
          pairs.calendar = {
            a = "local_calendar";
            b = "remote_calendar";
            collections = ["from b"];
            conflict_resolution = "b wins";
          };
        };
      };
    };
  };
}
