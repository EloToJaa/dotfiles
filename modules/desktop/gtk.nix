{
  pkgs,
  variables,
  ...
}: {
  gtk = {
    enable = true;
    font = {
      name = "JetBrainsMono Nerd Font";
      size = 11;
    };
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.catppuccin-papirus-folders.override {
        flavor = "${variables.catppuccin.flavor}";
        accent = "${variables.catppuccin.accent}";
      };
    };
    # theme = {
    #   name = "Dracula";
    #   package = pkgs.dracula-theme;
    # };
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
