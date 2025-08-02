{
  programs.ghostty = {
    enable = true;

    enableBashIntegration = true;
    enableZshIntegration = true;
    installBatSyntax = true;
    installVimSyntax = true;

    settings = {
      theme = "catppuccin-mocha";
      font-size = 12.4;
      font-family = "JetBrainsMono Nerd Font";
    };
  };
}
