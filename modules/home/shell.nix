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
        show_preview = true;
        store_failed = true;
        secrets_filter = true;
        enter_accept = true;
        keymap_mode = "vim-normal";
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
