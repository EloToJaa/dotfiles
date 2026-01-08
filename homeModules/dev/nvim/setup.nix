{
  lib,
  config,
  ...
}: let
  shellAliases = {
    vim = "nvim";
    vi = "nvim";
    v = "nvim";
  };
  cfg = config.modules.dev.nvim;
in {
  config = lib.mkIf cfg.enable {
    home.sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
      MANPAGER = "nvim +Man!";
    };

    programs = {
      zsh.shellAliases = shellAliases;
    };
  };
}
