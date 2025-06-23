{pkgs, ...}: {
  programs.nixvim = {
    enable = true;

    enableMan = true;

    package = pkgs.neovim;
  };
}
