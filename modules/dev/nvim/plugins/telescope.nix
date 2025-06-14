{pkgs, ...}: {
  programs.nvf.settings.vim.telescope = {
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
}
