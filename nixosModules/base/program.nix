{
  lib,
  config,
  ...
}: let
  cfg = config.modules.base;
in {
  options.modules.base.nix-ld.enable = lib.mkEnableOption "running external dynamically linked binaries";

  config = lib.mkIf cfg.enable {
    programs = {
      nix-ld.enable = cfg.nix-ld.enable;
      zsh.enable = true;
    };

    services.smartd.enable = true;
  };
}
