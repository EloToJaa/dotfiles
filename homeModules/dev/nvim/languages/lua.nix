{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.modules.dev.nvim.languages.lua;
in {
  options.modules.dev.nvim.languages.lua = {
    enable = lib.mkEnableOption "Enable lua";
  };
  config = lib.mkIf cfg.enable {
    home.packages = with pkgs.unstable; [
      lua54Packages.luacheck
      stylua
    ];

    programs.nixvim = {
      lsp.servers.lua_ls = {
        enable = true;
      };
      plugins = {
        lint.lintersByFt = {
          lua = ["luacheck"];
        };
        conform-nvim.settings.formatters_by_ft = {
          lua = ["stylua"];
        };
        treesitter.grammarPackages = with pkgs.unstable.vimPlugins.nvim-treesitter.builtGrammars; [
          lua
        ];
      };
    };
  };
}
