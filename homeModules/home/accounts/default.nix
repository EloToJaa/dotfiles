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
  passwordCommand = [
    "${pkgs.coreutils}/bin/cat"
    "/run/secrets/vars/accounts/dav-passwd"
  ];
in {
  options.modules.home.accounts = {
    enable = lib.mkEnableOption "Enable accounts";
  };
  config = lib.mkIf cfg.enable {
    accounts = {
      calendar = {
        basePath = "${localDir}/calendars";
        accounts = {
          xandikos = {
            khal = {
              enable = true;
              type = "discover";
              priority = 100;
            };
            vdirsyncer = {
              enable = true;
              conflictResolution = "remote wins";
              collections = [
                "from a"
                "from b"
              ];
              metadata = [
                "color"
                "displayname"
              ];
            };
            primary = true;
            primaryCollection = "personal";

            remote = {
              inherit passwordCommand;
              userName = username;
              type = "caldav";
              url = "https://dav.server.elotoja.com/";
            };
            local = {
              type = "filesystem";
              path = "${localDir}/calendars";
            };
          };
          sonarr = {
            khal = {
              enable = true;
              type = "calendar";
              priority = 50;
              readOnly = true;
            };
            vdirsyncer = {
              enable = true;
              conflictResolution = "remote wins";
            };

            remote = {
              inherit passwordCommand;
              userName = username;
              type = "http";
              url = "https://dav.server.elotoja.com/feeds/sonarr.ics";
            };
            local = {
              type = "filesystem";
              path = "${localDir}/calendars/sonarr";
            };
          };
          radarr = {
            khal = {
              enable = true;
              type = "calendar";
              priority = 50;
              readOnly = true;
            };
            vdirsyncer = {
              enable = true;
              conflictResolution = "remote wins";
            };

            remote = {
              inherit passwordCommand;
              userName = username;
              type = "http";
              url = "https://dav.server.elotoja.com/feeds/radarr.ics";
            };
            local = {
              type = "filesystem";
              path = "${localDir}/calendars/radarr";
            };
          };
        };
      };
      contact = {
        basePath = "${localDir}/contacts";
        accounts = {
          xandikos = {
            khal = {
              enable = true;
              priority = 1;
            };
            khard = {
              enable = true;
              type = "discover";
            };
            vdirsyncer = {
              enable = true;
              conflictResolution = "remote wins";
              collections = [
                "from a"
                "from b"
              ];
              metadata = [
                "displayname"
              ];
            };

            remote = {
              userName = username;
              type = "carddav";
              url = "https://dav.server.elotoja.com/";
              passwordCommand = [
                "${pkgs.coreutils}/bin/cat"
                "/run/secrets/vars/accounts/dav-passwd"
              ];
            };
            local = {
              type = "filesystem";
              path = "${localDir}/contacts";
            };
          };
        };
      };
    };
    services.vdirsyncer = {
      enable = true;
      package = pkgs.unstable.vdirsyncer;
    };
    programs = {
      vdirsyncer = {
        enable = true;
        package = pkgs.unstable.vdirsyncer;
      };
      khal = {
        enable = true;
        package = pkgs.unstable.khal;
        settings.default.default_calendar = "xandikos";
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
      khard = {
        enable = true;
        package = pkgs.unstable.khard;
      };
      todoman = {
        enable = true;
        package = pkgs.unstable.todoman;
        extraConfig = ''
          date_format = "%d/%m/%Y";
          time_format = "%H:%M";
          default_list = "personal";
          default_due = 48;
        '';
      };
    };
  };
}
