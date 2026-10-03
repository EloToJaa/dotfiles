{
  config,
  lib,
  ...
}: let
  cfg = config.modules.base;
in {
  config = lib.mkIf cfg.enable {
    programs = {
      nix-ld.enable = true;
      zsh.enable = true;
    };

    services.smartd.enable = true;
  };
}
