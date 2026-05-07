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
    settings = lib.mkOption {
      type = lib.types.attrsOf lib.types.anything;
      default = {};
      description = "Configuration options for programs.khal.settings.";
    };
    locale = lib.mkOption {
      type = lib.types.attrsOf lib.types.anything;
      default = {};
      description = "Locale options for programs.khal.locale.";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.khal = {
      enable = true;
      package = cfg.package;
      settings = cfg.settings;
      locale = cfg.locale;
    };
  };
}
