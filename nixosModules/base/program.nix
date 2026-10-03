{
  config,
  lib,
  ...
}: let
  cfg = config.modules.base;
in {
  config = lib.mkIf cfg.enable {
    programs = {
      zsh.enable = true;
    };

    services.smartd.enable = true;
  };
}
