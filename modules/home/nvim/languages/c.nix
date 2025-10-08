{
  pkgs,
  inputs,
  ...
}: {
  home.packages = with pkgs.unstable; [
    clang-tools
  ];

  nix.nixPath = ["nixpkgs=${inputs.nixpkgs}"];

  programs.nixvim = {
    lsp.servers.clangd = {
      enable = true;
    };
    plugins = {
      conform-nvim.settings.formatters_by_ft = {
        c = ["clang-format"];
        cpp = ["clang-format"];
      };
      treesitter.grammarPackages = with pkgs.unstable.vimPlugins.nvim-treesitter.builtGrammars; [
        c
        cpp
      ];
    };
  };
}
