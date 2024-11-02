{...}: {
  programs = {
    atuin = {
      enable = true;

      enableZshIntegration = true;
      enableNushellIntegration = true;
    };
    zoxide = {
      enable = true;

      enableZshIntegration = true;
      enableNushellIntegration = true;
    };
    eza = {
      enable = true;

      enableZshIntegration = true;
      enableNushellIntegration = false;

      git = true;
      icons = "auto";
    };
  };
}
