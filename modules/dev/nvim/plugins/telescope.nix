{
  programs.nixvim.plugins = {
    telescope = {
      enable = true;
      settings.defaults.mappings.i = {
        "<C-k>" = {
          __raw = "require('telescope.actions').move_selection_previous";
        };
        "<C-j>" = {
          __raw = "require('telescope.actions').move_selection_next";
        };
        "<C-q>" = {
          __raw = "require('telescope.actions').send_selected_to_qflist + require('telescope.actions').open_qflist";
        };
      };
      extensions.fzf-native = {
        enable = true;
        settings = {
          case_mode = "smart_case";
          fuzzy = true;
          override_generic_sorter = true;
          override_file_sorter = true;
        };
      };
      keymaps = {
        "<C-p>" = {
          action = "find_files";
          options.desc = "Telescope git files";
        };
        "<leader>fs" = {
          action = "live_grep";
          options.desc = "Live grep";
        };
        "<leader>ff" = {
          action = "find_files";
          options.desc = "Find files";
        };
        "<leader>ft" = {
          action = "treesitter";
          options.desc = "Treesitter";
        };
        "<leader>fb" = {
          action = "buffers";
          options.desc = "Buffers";
        };
        "<leader>fh" = {
          action = "help_tags";
          options.desc = "Help tags";
        };
        "<leader>fr" = {
          action = "resume";
          options.desc = "Resume";
        };
        "<leader>fgc" = {
          action = "git_commits";
          options.desc = "Git commits";
        };
        "<leader>fgb" = {
          action = "git_branches";
          options.desc = "Git branches";
        };
        "<leader>fgs" = {
          action = "git_status";
          options.desc = "Git status";
        };
        "<leader>fgd" = {
          action = "git_bcommits";
          options.desc = "Git buffer commits";
        };
        "<leader>fgf" = {
          action = "git_files";
          options.desc = "Find files";
        };
        "<leader>fyb" = {
          action = "lsp_document_symbols";
          options.desc = "LSP document symbols";
        };
        "<leader>fyw" = {
          action = "lsp_workspace_symbols";
          options.desc = "LSP workspace symbols";
        };
        "gR" = {
          action = "lsp_references";
          options.desc = "LSP references";
        };
        "gi" = {
          action = "lsp_implementations";
          options.desc = "LSP implementations";
        };
        "gd" = {
          action = "lsp_definitions";
          options.desc = "LSP definitions";
        };
        "gt" = {
          action = "lsp_type_definitions";
          options.desc = "LSP type definitions";
        };
        "<leader>fd" = {
          action = "diagnostics";
          options.desc = "LSP document diagnostics";
        };
      };
    };
    web-devicons.enable = true;
    which-key.settings.spec = [
      {
        __unkeyed-1 = "<leader>f";
        group = "Telescope";
        icon = "";
      }
      {
        __unkeyed-1 = "<leader>fy";
        group = "LSP symbols";
      }
      {
        __unkeyed-1 = "<leader>fg";
        group = "Git";
      }
    ];
  };
}
