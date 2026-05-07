{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.modules.base.vdirsyncer;
in {
  options.modules.base.vdirsyncer = {
    enable = lib.mkEnableOption "Enable vdirsyncer";
    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.vdirsyncer;
      description = "The vdirsyncer package to use.";
    };
    jobs = lib.mkOption {
      type = lib.types.attrsOf lib.types.anything;
      default = {};
      description = "Vdirsyncer job configurations forwarded to services.vdirsyncer.jobs.";
    };
  };

  config = lib.mkIf cfg.enable {
    services.vdirsyncer = {
      enable = true;
      package = cfg.package;
      jobs = cfg.jobs;
    };
  };
}
