{pkgs, ...}: {
  programs.nixvim = {
    enable = true;

    enableMan = true;
    defaultEditor = true;

    # package = pkgs.neovim;
  };
}
