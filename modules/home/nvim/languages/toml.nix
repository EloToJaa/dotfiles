{pkgs, ...}: {
  programs.nixvim = {
    lsp.servers.taplo = {
      enable = true;
    };
    plugins = {
      treesitter.grammarPackages = with pkgs.unstable.vimPlugins.nvim-treesitter.builtGrammars; [
        toml
      ];
    };
  };
}
