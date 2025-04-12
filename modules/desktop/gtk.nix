{
  pkgs,
  variables,
  ...
}: {
  home.packages = with pkgs; [
    nwg-look
  ];

  home.sessionVariables = {
    GTK_THEME = "Orchis-Dark-Compact";
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
        flavor = "${variables.catppuccin.flavor}";
        accent = "${variables.catppuccin.accent}";
      };
    };
    theme = {
      name = "Orchis-Dark-Compact";
      package = pkgs.orchis-theme.override {
        tweaks = [
          "black"
          "primary"
        ];
      };
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
