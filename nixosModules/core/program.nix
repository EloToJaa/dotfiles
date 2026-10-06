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
    developer.enable = lib.mkEnableOption "package maintenance tools";
  };
  config = lib.mkIf cfg.enable {
    programs.gnupg.agent = lib.mkIf cfg.gnupg.enable {
      enable = true;
      enableSSHSupport = true;
    };
    environment.systemPackages = lib.mkIf cfg.developer.enable [pkgs.unstable.nix-update];
    modules.shared.graphics = {
      enable = lib.mkDefault true;
      enable32Bit = lib.mkDefault true;
    };
  };
}
