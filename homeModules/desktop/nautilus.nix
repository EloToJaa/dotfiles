{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.modules.desktop.nautilus;
in {
  options.modules.desktop.nautilus = {
    enable = lib.mkEnableOption "Enable nautilus";
  };
  config = lib.mkIf cfg.enable {
    home.packages = with pkgs.unstable; [nautilus];

    dconf.settings = {
      "org/gnome/nautilus/preferences" = {
        always-use-browser-view = true;
        click-policy = "double";
        date-format = "iso";
        show-hidden-files = true;
        show-delete-permanently = true;
        show-create-link = true;
        search-view = "list-view";
        default-folder-view = "list-view";
      };
      "org/gnome/nautilus/icon-view" = {
        default-zoom-level = "small";
      };
      "org/gnome/nautilus/list-view" = {
        default-zoom-level = "small";
      };
      "org/gnome/nautilus/window-state" = {
        maximized = false;
        sidebar-width = 220;
        start-with-sidebar = true;
      };
    };

    xdg.configFile."gtk-3.0/bookmarks".text = let
      home = config.home.homeDirectory;
    in ''
      file://${home}
      file://${home}/Downloads
      file://${home}/Desktop
      file://${home}/Documents
      file://${home}/Pictures
      file://${home}/Projects
      file://${home}/Videos
      file:///
      file:///mnt/data
    '';
  };
}
