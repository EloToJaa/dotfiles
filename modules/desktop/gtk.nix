{
  pkgs,
  variables,
  ...
}: let
  # theme = "Orchis-Dark-Compact";
  theme = "Adwaita-dark";
in {
  home.packages = with pkgs; [
    nwg-look
  ];

  home.sessionVariables = {
    GTK_THEME = theme;
  };

  gtk = {
    enable = true;
    font = {
      name = "JetBrainsMono Nerd Font";
      size = 11;
    };
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.catppuccin-papirus-folders.override {
        flavor = variables.catppuccin.flavor;
        accent = variables.catppuccin.accent;
      };
    };
    theme = {
      name = theme;
      # package = pkgs.orchis-theme.override {
      #   tweaks = ["primary"];
      # };
    };
    cursorTheme = {
      name = "Bibata-Modern-Ice";
      package = pkgs.bibata-cursors;
      size = 22;
    };
  };

  home.pointerCursor = {
    name = "Bibata-Modern-Ice";
    package = pkgs.bibata-cursors;
    size = 22;
  };
}
