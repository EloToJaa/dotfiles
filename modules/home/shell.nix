{...}: {
  programs.atuin = {
    enable = true;

    enableZshIntegration = true;
  };

  programs.zoxide = {
    enable = true;

    enableZshIntegration = true;
  };

  programs.eza = {
    enable = true;

    enableZshIntegration = true;

    git = true;
    icons = "auto";
  };
}
