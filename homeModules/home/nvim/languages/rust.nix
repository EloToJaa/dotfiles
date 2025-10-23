{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.modules.home.nvim.languages.rust;
in {
  options.modules.home.nvim.languages.rust = {
    enable = lib.mkEnableOption "Enable rust";
  };
  config = lib.mkIf cfg.enable {
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
  };
}
