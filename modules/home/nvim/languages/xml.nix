{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.modules.home.nvim.languages.xml;
in {
  options.modules.home.nvim.languages.xml = {
    enable = lib.mkEnableOption "Enable xml";
  };
  config = lib.mkIf cfg.enable {
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
  };
}
