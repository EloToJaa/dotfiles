{
  pkgs,
  lib,
  config,
  settings,
  ...
}: let
  inherit (settings) catppuccin;
  theme = "adw-gtk3-dark";
  cfg = config.modules.desktop.gtk;
  pointerPackage = pkgs.unstable.bibata-cursors;
  iconsPackage = pkgs.unstable.catppuccin-papirus-folders.override {
    inherit (catppuccin) flavor accent;
  };
  themePackage = pkgs.unstable.adw-gtk3;
  cursorTheme = {
    name = "Bibata-Modern-Ice";
    package = pointerPackage;
    size = 22;
  };
in {
  options.modules.desktop.gtk = {
    enable = lib.mkEnableOption "Enable gtk";
    applyTheme = lib.mkEnableOption "Apply theme";
  };
  config = lib.mkIf cfg.enable {
    home.packages = with pkgs.unstable; [
      nwg-look
      themePackage
      pointerPackage
      iconsPackage
    ];

    home = {
      sessionVariables = lib.mkIf cfg.applyTheme {
        GTK_THEME = theme;
      };
      pointerCursor = cursorTheme;
    };

    gtk = lib.mkIf cfg.applyTheme {
      inherit cursorTheme;
      enable = true;
      colorScheme = "dark";
      font = {
        name = "JetBrainsMono Nerd Font";
        size = 11;
      };
      iconTheme = {
        name = "Papirus-Dark";
        package = iconsPackage;
      };
      theme = {
        name = theme;
        package = themePackage;
      };
      gtk4.theme = config.gtk.theme;
    };
  };
}
