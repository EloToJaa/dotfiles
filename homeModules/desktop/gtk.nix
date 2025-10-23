{
  pkgs,
  lib,
  config,
  ...
}: let
  inherit (config.settings) catppuccin;
  # theme = "Orchis-Dark-Compact";
  theme = "Adwaita-dark";
  cfg = config.modules.desktop.gtk;
in {
  options.modules.desktop.gtk = {
    enable = lib.mkEnableOption "Enable gtk";
  };
  config = lib.mkIf cfg.enable {
    home.packages = with pkgs.unstable; [
      nwg-look
    ];

    home = {
      sessionVariables = {
        GTK_THEME = theme;
      };
      pointerCursor = {
        name = "Bibata-Modern-Ice";
        package = pkgs.unstable.bibata-cursors;
        size = 22;
      };
    };

    gtk = {
      enable = true;
      font = {
        name = "JetBrainsMono Nerd Font";
        size = 11;
      };
      iconTheme = {
        name = "Papirus-Dark";
        package = lib.mkForce (pkgs.unstable.catppuccin-papirus-folders.override {
          inherit (catppuccin) flavor accent;
        });
      };
      theme = {
        name = theme;
        # package = pkgs.orchis-theme.override {
        #   tweaks = ["primary"];
        # };
      };
      cursorTheme = {
        name = "Bibata-Modern-Ice";
        package = pkgs.unstable.bibata-cursors;
        size = 22;
      };
    };
  };
}
