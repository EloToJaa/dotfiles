{pkgs, ...}: {
  home.packages = with pkgs.unstable; [
    rustfmt
  ];

  programs.nixvim = {
    lsp.servers.rust_analyzer = {
      enable = true;

      config = {
        imports = {
          granularity.group = "module";
          prefix = "crate";
        };
        cargo = {
          allFeatures = true;
          buildScripts.enable = true;
        };
        checkOnSave.command = "clippy";
        procMacro.enable = true;
      };
    };
    plugins = {
      conform-nvim.settings.formatters_by_ft = {
        rust = ["rustfmt"];
      };
      treesitter.grammarPackages = with pkgs.unstable.vimPlugins.nvim-treesitter.builtGrammars; [
        rust
      ];
    };
  };
}
