{pkgs, ...}: {
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
}
