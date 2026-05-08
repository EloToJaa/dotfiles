{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.modules.core.vdirsyncer;
  inherit (config.settings) username;
  dav = "https://dav.server.elotoja.com/";
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
              url = dav;
            };
            local_contacts = {
              type = "filesystem";
              path = "/home/${username}/.local/share/contacts/";
              fileext = ".vcf";
            };
            remote_contacts = {
              type = "carddav";
              url = dav;
            };
          };
          pairs.calendar = {
            a = "local_calendar";
            b = "remote_calendar";
            collections = ["from b"];
            conflict_resolution = "b wins";
          };
          pairs.contacts = {
            a = "local_contacts";
            b = "remote_contacts";
            collections = ["from b"];
            conflict_resolution = "b wins";
          };
        };
      };
    };
  };
}
