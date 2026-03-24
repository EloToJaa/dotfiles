{
  pkgs,
  lib,
  config,
  settings,
  ...
}: let
  inherit (settings) catppuccin;
  # theme = "Orchis-Dark-Compact";
  theme = "Adwaita-dark";
  cfg = config.modules.desktop.gtk;
  pointerPackage = pkgs.unstable.bibata-cursors;
  iconsPackage = pkgs.unstable.catppuccin-papirus-folders.override {
    inherit (catppuccin) flavor accent;
  };
in {
  options.modules.desktop.gtk = {
    enable = lib.mkEnableOption "Enable gtk";
    applyTheme = lib.mkEnableOption "Apply theme";
  };
  config = lib.mkIf cfg.enable {
    home.packages = with pkgs.unstable; [
      nwg-look
      adw-gtk3
      pointerPackage
      iconsPackage
    ];

    home = {
      sessionVariables = lib.mkIf cfg.applyTheme {
        GTK_THEME = theme;
      };
      pointerCursor = {
        name = "Bibata-Modern-Ice";
        package = pointerPackage;
        size = 22;
      };
    };

    gtk = lib.mkIf cfg.applyTheme {
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
        # package = pkgs.orchis-theme.override {
        #   tweaks = ["primary"];
        # };
      };
      cursorTheme = config.home.pointerCursor;
      gtk4.theme = config.gtk.theme;
    };
  };
}
