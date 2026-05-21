{
  config,
  lib,
  ...
}: let
  cfg = config.modules.home;
in {
  config = lib.mkIf cfg.enable {
    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
      enableZshIntegration = true;
    };
  };
}
