{
  config,
  lib,
  pkgs,
  settings,
  ...
}: let
  inherit (settings) timezone username;
  cfg = config.modules.home.accounts;
  localDir = "${config.home.homeDirectory}/.local/share";
in {
  options.modules.home.accounts = {
    enable = lib.mkEnableOption "Enable accounts";
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
          userName = username;
          type = "caldav";
          url = "https://dav.server.elotoja.com/";
          passwordCommand = [
            "${pkgs.coreutils}/bin/cat"
            config.clan.core.vars.generators.dav-password.files.passwd.path
          ];
        };
        local = {
          type = "filesystem";
          path = "${localDir}/calendars/xandikos";
        };
      };
    };
    programs.vdirsyncer = {
      enable = true;
      package = pkgs.unstable.vdirsyncer;
    };
    services.vdirsyncer = {
      enable = true;
      package = pkgs.unstable.vdirsyncer;
    };
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
