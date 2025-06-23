{pkgs, ...}: {
  programs.nixvim = {
    enable = true;

    enableMan = true;

    build.package = pkgs.neovim;
  };
}
