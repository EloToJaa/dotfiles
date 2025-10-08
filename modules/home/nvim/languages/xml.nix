{pkgs, ...}: {
  programs.nixvim = {
    lsp.servers.lemminx = {
      enable = true;
    };
    plugins = {
      treesitter.grammarPackages = with pkgs.unstable.vimPlugins.nvim-treesitter.builtGrammars; [
        xml
      ];
    };
  };
}
