{
  lib,
  config,
  ...
}: let
  inherit (config.lib.nixvim) mkRaw;
  cfg = config.modules.dev.nvim.plugins.telescope;
in {
  options.modules.dev.nvim.plugins.telescope = {
    enable = lib.mkEnableOption "Enable telescope";
  };
  config = lib.mkIf cfg.enable {
    programs.nixvim.plugins = {
      telescope = {
        enable = true;
        settings = {
          defaults = {
            mappings.i = {
              "<C-k>" = mkRaw "require('telescope.actions').move_selection_previous";
              "<C-j>" = mkRaw "require('telescope.actions').move_selection_next";
            };
            file_ignore_patterns = ["^%.git/" "^%.venv/" "^node_modules/"];
          };
          pickers = {
            find_files.hidden = true;
            live_grep.additional_args = mkRaw "function(_) return { '--hidden' } end";
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
            options.desc = "Find files";
          };
          "<leader>ff" = {
            action = "find_files";
            options.desc = "Find files";
          };
          "<leader>fs" = {
            action = "live_grep";
            options.desc = "Live grep";
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
          "<leader>gfc" = {
            action = "git_commits";
            options.desc = "Git commits";
          };
          "<leader>gfb" = {
            action = "git_branches";
            options.desc = "Git branches";
          };
          "<leader>gfs" = {
            action = "git_status";
            options.desc = "Git status";
          };
          "<leader>gfd" = {
            action = "git_bcommits";
            options.desc = "Git buffer commits";
          };
          "<leader>gff" = {
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
          __unkeyed-1 = "<leader>gf";
          group = "Find";
        }
      ];
    };
  };
}
