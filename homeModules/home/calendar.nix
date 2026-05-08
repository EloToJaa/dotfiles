{
  config,
  lib,
  pkgs,
  settings,
  ...
}: let
  inherit (settings) timezone;
  cfg = config.modules.home.calendar;
  localDir = "${config.home.homeDirectory}/.local/share";
in {
  options.modules.home.calendar = {
    enable = lib.mkEnableOption "Enable khal";
  };

  config = lib.mkIf cfg.enable {
    accounts.calendar.accounts = {
      xandikos = {
        khal = {
          enable = true;
          type = "discover";
          priority = 1;
        };

        vdirsyncer = {
          enable = true;
          collections = [
            "from a"
            "from b"
          ];
          metadata = [
            "color"
            "displayname"
          ];
        };

        remote = {
          type = "caldav";
          url = "https://dav.server.elotoja.com/";
        };
        local = {
          type = "filesystem";
          path = "${localDir}/calendars/xandikos";
        };
      };
    };
    programs.vdirsyncer.enable = true;
    services.vdirsyncer.enable = true;
    programs.khal = {
      enable = true;
      package = pkgs.unstable.khal;
      settings.default.default_calendar = "personal";
      locale = {
        timeformat = "%H:%M";
        dateformat = "%d/%m/%Y";
        longdateformat = "%d/%m/%Y";
        datetimeformat = "%d/%m/%Y %H:%M";
        longdatetimeformat = "%d/%m/%Y %H:%M";
        default_timezone = timezone;
        local_timezone = timezone;
      };
    };
  };
}
