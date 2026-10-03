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
    nix-ld.enable = lib.mkEnableOption "running external dynamically linked binaries";
    developer.enable = lib.mkEnableOption "package maintenance tools";
  };
  config = lib.mkIf cfg.enable {
    programs.gnupg.agent = lib.mkIf cfg.gnupg.enable {
      enable = true;
      enableSSHSupport = true;
    };
    programs.nix-ld.enable = cfg.nix-ld.enable;
    environment.systemPackages = lib.mkIf cfg.developer.enable [pkgs.unstable.nix-update];
    modules.shared.graphics = {
      enable = lib.mkDefault true;
      enable32Bit = lib.mkDefault true;
    };
  };
}
