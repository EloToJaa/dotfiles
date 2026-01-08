{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.modules.dev.nvim.languages.go;
in {
  options.modules.dev.nvim.languages.go = {
    enable = lib.mkEnableOption "Enable go";
  };
  config = lib.mkIf cfg.enable {
    home.packages = with pkgs.unstable; [
      gofumpt
      gopls
    ];

    programs.nixvim = {
      lsp.servers.gopls = {
        enable = true;
        package = null;
        config = {
          analyses.unusedparams = true;
          staticcheck = true;
          gofumpt = true;
        };
      };
      plugins = {
        conform-nvim.settings.formatters_by_ft = {
          go = ["gofumpt"];
        };
        treesitter.grammarPackages = with pkgs.unstable.vimPlugins.nvim-treesitter.builtGrammars; [
          go
        ];
      };
    };
  };
}
