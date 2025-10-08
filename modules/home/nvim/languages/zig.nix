{pkgs, ...}: {
  programs.nixvim = {
    lsp.servers.zls = {
      enable = true;
    };
    plugins = {
      treesitter.grammarPackages = with pkgs.unstable.vimPlugins.nvim-treesitter.builtGrammars; [
        zig
      ];
    };
  };
}
