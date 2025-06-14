{
  pkgs,
  config,
  ...
}: {
  programs.nvf.settings.vim = {
    telescope = {
      enable = true;

      mappings = {
        findFiles = "<C-p>";
        liveGrep = "<leader>fs";
        treesitter = "<leader>ff";

        gitCommits = "<leader>fgc";
        gitBufferCommits = "<leader>fgf";
        gitBranches = "<leader>fgb";
        gitStatus = "<leader>fgs";
        gitStash = "<leader>fgx";
      };

      extensions = [
        {
          name = "fzf";
          packages = [pkgs.vimPlugins.telescope-fzf-native-nvim];
          setup = {
            fzf = {
              fuzzy = true;
              override_generic_sorter = true;
              override_file_sorter = true;
              case_mode = "smart_case";
            };
          };
        }
      ];
    };
    binds.whichKey.register =
      builtins.removeAttrs config.programs.nvf.settings.vim.binds.whichKey.register [
        "<leader>fv"
        "<leader>fvc"
      ]
      // {
        "<leader>fg" = "Telescope Git";
        "<leader>fgc" = "Commits";
      };
  };
}
