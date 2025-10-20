{
  config,
  lib,
  ...
}: let
  default = [
    "vim"
    "nvim"
    "less"
    "more"
    "man"
    "tig"
    "watch"
    "git commit"
    "top"
    "htop"
    "ssh"
    "nano"
  ];
  cfg = config.modules.home.zsh.plugins.auto-notify;
in {
  config = lib.mkIf cfg.enable {
    programs.zsh.localVariables.AUTO_NOTIFY_IGNORE =
      default
      ++ [
        "atuin"
        "yadm"
        "emacs"
        "nix-shell"
        "nix"
        "nix develop"
        "fg"
        "yazi"
        "tmux"
        "y"
      ];
  };
}
