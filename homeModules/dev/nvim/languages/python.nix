{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.modules.dev.nvim.languages.python;
in {
  options.modules.dev.nvim.languages.python = {
    enable = lib.mkEnableOption "Enable python";
  };
  config = lib.mkIf cfg.enable {
    home.packages = with pkgs.unstable; [
      ruff
      pyright
    ];

    programs.nixvim = {
      lsp.servers.pyright = {
        enable = true;
        package = null;
        config = {
          pyright.disableOrganizeImports = true;
          python.analysis.ignore = {
            __unkeyed-1 = "*";
          };
        };
      };
      plugins = {
        lint.lintersByFt = {
          python = ["ruff"];
        };
        conform-nvim.settings = {
          formatters_by_ft = {
            python = ["ruff" "ruff_organize_imports"];
          };
          formatters = {
            ruff_organize_imports = {
              command = "ruff";
              args = [
                "check"
                "--force-exclude"
                "--select=I001"
                "--fix"
                "--exit-zero"
                "--stdin-filename"
                "$FILENAME"
                "-"
              ];
              stdin = true;
              cwd = config.lib.nixvim.mkRaw ''
                require("conform.util").root_file({
                  "pyproject.toml",
                  "ruff.toml",
                  ".ruff.toml",
                })
              '';
            };
          };
        };
        treesitter.grammarPackages = with pkgs.unstable.vimPlugins.nvim-treesitter.builtGrammars; [
          python
        ];
      };
    };
  };
}
