{pkgs, ...}: {
  fonts.fontconfig.enable = true;
  home.packages = with pkgs; [
    # Nerd Fonts
    nerd-fonts.caskaydia-cove
    nerd-fonts.noto
    nerd-fonts.jetbrains-mono
    nerd-fonts.symbols-only
  ];
}
