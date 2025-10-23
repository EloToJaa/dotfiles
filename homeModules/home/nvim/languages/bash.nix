{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.modules.home.nvim.languages.bash;
in {
  options.modules.home.nvim.languages.bash = {
    enable = lib.mkEnableOption "Enable bash";
  };
  config = lib.mkIf cfg.enable {
    home.packages = with pkgs.unstable; [
      shfmt
    ];

    programs.nixvim = {
      lsp.servers.bashls = {
        enable = true;
        config = {
          cmd = [
            "bash-language-server"
            "start"
          ];
          filetypes = ["sh" "zsh" "bash"];
        };
      };
      plugins = {
        conform-nvim.settings.formatters_by_ft = {
          sh = ["shfmt"];
          bash = ["shfmt"];
          zsh = ["shfmt"];
        };
        treesitter.grammarPackages = with pkgs.unstable.vimPlugins.nvim-treesitter.builtGrammars; [
          bash
        ];
      };
    };
  };
}
