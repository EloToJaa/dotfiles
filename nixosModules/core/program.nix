{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.modules.core;
in {
  options.modules.core = {
    nix-ld.enable = lib.mkEnableOption "running external dynamically linked binaries";
    gnupg.enable = lib.mkEnableOption "GnuPG agent with SSH support";
  };
  config = lib.mkIf cfg.enable {
    programs.nix-ld.enable = cfg.nix-ld.enable;
    programs.gnupg.agent = lib.mkIf cfg.gnupg.enable {
      enable = true;
      enableSSHSupport = true;
    };
    modules.shared.graphics = {
      enable = lib.mkDefault true;
      enable32Bit = lib.mkDefault true;
    };
  };
}
