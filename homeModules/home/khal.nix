{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.modules.home.khal;
in {
  options.modules.home.khal = {
    enable = lib.mkEnableOption "Enable khal";
    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.khal;
      description = "The khal package to use.";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.khal = {
      inherit (cfg) package;
      enable = true;
      settings = {
        "calendars main" = {
          path = "~/.local/share/calendars/*";
          type = "discover";
        };
      };
      locale = {
        timeformat = "%H:%M";
        dateformat = "%Y-%m-%d";
        longdateformat = "%Y-%m-%d";
        datetimeformat = "%Y-%m-%d %H:%M";
        longdatetimeformat = "%Y-%m-%d %H:%M";
        default_timezone = "Europe/Warsaw";
        local_timezone = "Europe/Warsaw";
      };
    };
  };
}
