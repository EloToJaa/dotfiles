{pkgs, ...}: {
  home.packages = with pkgs; [
    tealdeer # tldr replacement
  ];

  xdg.configFile."tldr/config.toml".text =
    /*
    toml
    */
    ''
      [display]
      use_pager = true
      compact = true

      [updates]
      auto_update = true
      auto_update_interval_hours = 24
    '';
}
