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
      csharpier
    ];

    programs.nixvim = {
      lsp.servers.roslyn_ls = {
        enable = true;
        package = null;
      };
      plugins = {
        conform-nvim.settings.formatters_by_ft = {
          cs = ["csharpier"];
          csproj = ["csharpier"];
        };
        treesitter.grammarPackages = with pkgs.unstable.vimPlugins.nvim-treesitter.builtGrammars; [
          c_sharp
        ];
      };
      autoCmd = [
        {
          event = "FileType";
          pattern = "cs";
          callback = config.lib.nixvim.mkRaw ''
            function()
              vim.bo.indentexpr = ""
              vim.bo.cindent = true
              vim.bo.autoindent = true
              vim.bo.shiftwidth = 4
              vim.bo.tabstop = 4
              vim.bo.softtabstop = 4
              vim.bo.expandtab = true
            end
          '';
        }
      ];
    };
  };
}
