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
      enableNushellIntegration = true;

      git = true;
      icons = "auto";
    };
  };
}
