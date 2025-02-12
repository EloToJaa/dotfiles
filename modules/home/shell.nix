{
  variables,
  host,
  ...
}: let
  atuin =
    if (host == "desktop" || host == "server")
    then variables.atuin.local
    else variables.atuin.remote;
in {
  programs = {
    atuin = {
      enable = true;

      enableZshIntegration = true;

      settings = {
        auto_sync = true;
        sync_frequency = "10m";
        sync_address = atuin;
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
    };
    eza = {
      enable = true;

      enableZshIntegration = true;

      git = true;
      icons = "auto";
    };
    carapace = {
      enable = true;

      enableZshIntegration = true;
    };
    nushell.enable = false;
  };
}
