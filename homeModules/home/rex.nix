{
  config,
  inputs,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkOption mkEnableOption types;
  cfg = config.modules.home.rex;
in {
  options.modules.home.rex = {
    enable = mkEnableOption "Enable rex terminal multiplexer";
    server.enable = mkEnableOption "Run a personal rex server as a systemd user service";
    client.enable = mkEnableOption "Install the unofficial Rex Rune desktop client";
    config = mkOption {
      type = types.nullOr (types.either types.lines types.path);
      default = null;
      description = "Lua configuration written to ~/.config/rex/init.lua";
    };
  };
  config = lib.mkIf cfg.enable {
    programs.rex = {
      enable = true;
      inherit (cfg) config;
      # the guard is added through home-manager's ~/.ssh/config, which is unmanaged here
      sshGuard = lib.mkDefault config.programs.ssh.enable;
    };
    services.rex.enable = cfg.server.enable;
    home.packages = lib.optionals cfg.client.enable [
      inputs.rex-rune.packages.${pkgs.stdenv.hostPlatform.system}.default
    ];
  };
}
