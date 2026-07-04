{
  pkgs,
  config,
  lib,
  settings,
  ...
}: let
  inherit (settings) catppuccin;
  cfg = config.modules.home.fzf;
in {
  options.modules.home.fzf = {
    enable = lib.mkEnableOption "Enable fzf";
  };
  config = lib.mkIf cfg.enable {
    programs.fzf = {
      enable = true;
      package = pkgs.unstable.fzf;
      enableZshIntegration = true;

      defaultCommand = "fd --hidden --strip-cwd-prefix --exclude .git";
      fileWidget.options = ["--preview 'if [ -d {} ]; then eza --tree --color=always {} | head -200; else bat -n --color=always --line-range :500 {}; fi'"];
      changeDirWidget.command = "fd --type=d --hidden --strip-cwd-prefix --exclude .git";
      changeDirWidget.options = ["--preview 'eza --tree --color=always {} | head -200'"];
      historyWidget.command = "";
    };
    catppuccin.fzf = {
      enable = true;
      inherit (catppuccin) flavor;
    };
  };
}
