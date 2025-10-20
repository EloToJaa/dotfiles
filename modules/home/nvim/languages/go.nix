{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.modules.home.nvim.languages.go;
in {
  options.modules.home.nvim.languages.go = {
    enable = lib.mkEnableOption "Enable go";
  };
  config = lib.mkIf cfg.enable {
    home.packages = with pkgs.unstable; [
      gofumpt
    ];

    programs.nixvim = {
      lsp.servers.gopls = {
        enable = true;
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
