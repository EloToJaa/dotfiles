{lib, ...}: {
  options.modules.home.zsh = {
    enable = lib.mkEnableOption "Enable zsh";
    plugins = {
      enable = lib.mkEnableOption "Enable zsh plugins";
      zsh-vi-mode.enable = lib.mkEnableOption "Enable zsh-vi-mode";
      zsh-autopair.enable = lib.mkEnableOption "Enable zsh-autopair";
      zsh-fzf-tab.enable = lib.mkEnableOption "Enable zsh-fzf-tab";
      zsh-auto-notify.enable = lib.mkEnableOption "Enable zsh-auto-notify";
      zsh-autosuggestions-abbreviations-strategy.enable = lib.mkEnableOption "Enable zsh-autosuggestions-abbreviations-strategy";
      zsh-system-clipboard.enable = lib.mkEnableOption "Enable zsh-system-clipboard";
      zsh-zhooks.enable = lib.mkEnableOption "Enable zsh-zhooks";
      zsh-abbr.enable = lib.mkEnableOption "Enable zsh-abbr";
    };
  };
  imports = [
    ./autoNotifyIgnore.nix
    ./initContent.nix
    ./plugins.nix
    ./zsh.nix
    ./zshAbbr.nix
  ];
}
