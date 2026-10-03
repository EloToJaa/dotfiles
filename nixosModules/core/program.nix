{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.modules.core;
in {
  options.modules.core = {
    gnupg.enable = lib.mkEnableOption "GnuPG agent with SSH support";
  };
  config = lib.mkIf cfg.enable {
    programs.gnupg.agent = lib.mkIf cfg.gnupg.enable {
      enable = true;
      enableSSHSupport = true;
    };
  };
}
