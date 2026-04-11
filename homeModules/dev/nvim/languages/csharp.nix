{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.modules.dev.nvim.languages.csharp;
in {
  options.modules.dev.nvim.languages.csharp = {
    enable = lib.mkEnableOption "Enable c#";
  };
  config = lib.mkIf cfg.enable {
    home.packages = with pkgs.unstable; [
      dotnetCorePackages.sdk_10_0
      roslyn-ls
    ];

    programs.nixvim = {
      lsp.servers.roslyn_ls = {
        enable = true;
        package = null;
      };
      plugins = {
        # roslyn = {
        #   enable = true;
        #   package = pkgs.unstable.vimPlugins.roslyn-nvim;
        # };
        # conform-nvim.settings.formatters_by_ft = {
        #   cs = ["clang-format"];
        # };
        treesitter.grammarPackages = with pkgs.unstable.vimPlugins.nvim-treesitter.builtGrammars; [
          c_sharp
        ];
      };
    };
  };
}
