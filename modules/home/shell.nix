{...}: {
  programs = {
    atuin = {
      enable = true;

      enableZshIntegration = true;
      enableNushellIntegration = true;

      settings = {
        auto_sync = true;
        sync_frequency = "10m";
        sync_address = "https://atuin.local.elotoja.com";
      };
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
    carapace = {
      enable = true;

      enableZshIntegration = true;
      enableNushellIntegration = true;
    };
  };
}
