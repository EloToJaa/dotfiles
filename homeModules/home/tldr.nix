{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.modules.home.tldr;
in {
  options.modules.home.tldr = {
    enable = lib.mkEnableOption "Enable tldr";
  };
  config = lib.mkIf cfg.enable {
    home.packages = with pkgs.unstable; [
      tealdeer # tldr replacement
    ];

    xdg.configFile."tealdeer/config.toml".text =
      /*
      toml
      */
      ''
        [display]
        use_pager = false
        compact = false

        [updates]
        auto_update = true
        auto_update_interval_hours = 24
      '';
  };
}
