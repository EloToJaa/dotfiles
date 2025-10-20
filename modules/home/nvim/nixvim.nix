{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.modules.home.nvim;
in {
  config = lib.mkIf cfg.enable {
    programs.nixvim = {
      enable = true;

      enableMan = true;
      defaultEditor = true;

      package = pkgs.unstable.neovim-unwrapped;
    };
  };
}
