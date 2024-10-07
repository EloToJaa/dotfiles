{ pkgs, config, ... }:
let 
  monolisa = pkgs.callPackage ../../pkgs/monolisa/monolisa.nix {}; 
  monolisa-nerd = pkgs.callPackage ../../pkgs/monolisa/monolisa-nerd.nix { inherit monolisa; }; 
in
{
  fonts.fontconfig.enable = true;
  home.packages = with pkgs; [
    (nerdfonts.override { fonts = [
      "JetBrainsMono"
      "FiraCode"
      "CascadiaCode"
      "NerdFontsSymbolsOnly"
    ]; })
    twemoji-color-font
    noto-fonts-emoji
    # monolisa
    # monolisa-nerd
  ];

  gtk = {
    enable = true;
    font = {
      name = "CaskaydiaCove Nerd Font";
      size = 12;
    };
    catppuccin = {
      enable = true;
      flavor = "mocha";
      accent = "lavender";
      size = "standard";
      tweaks = [ "normal" ];
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
