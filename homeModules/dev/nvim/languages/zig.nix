{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.modules.dev.nvim.languages.zig;
in {
  options.modules.dev.nvim.languages.zig = {
    enable = lib.mkEnableOption "Enable zig";
  };
  config = lib.mkIf cfg.enable {
    home.packages = with pkgs.unstable; [
      # zls
    ];

    programs.nixvim = {
      lsp.servers.zls = {
        enable = true;
        package = null;
      };
      plugins = {
        treesitter.grammarPackages = with pkgs.unstable.vimPlugins.nvim-treesitter.builtGrammars; [
          zig
        ];
      };
    };
  };
}
