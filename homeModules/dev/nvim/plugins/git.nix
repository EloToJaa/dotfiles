{
  config,
  lib,
  ...
}: let
  inherit (config.lib.nixvim) mkRaw;
  cfg = config.modules.dev.nvim.plugins.git;
in {
  options.modules.dev.nvim.plugins.git = {
    enable = lib.mkEnableOption "Enable git";
  };
  config = lib.mkIf cfg.enable {
    programs.nixvim = {
      plugins = {
        lazygit.enable = config.modules.dev.lazygit.enable;
        fugitive.enable = true;
        gitsigns = {
          enable = true;
          settings = {
            watch_gitdir = {
              enable = true;
              follow_files = true;
            };
            current_line_blame = true;
          };
        };
        git-worktree = {
          enable = true;
          enableTelescope = true;
          settings = {
            change_directory_command = "cd";
            update_on_change = true;
          };
        };
        lz-n.keymaps = lib.optionals config.modules.dev.lazygit.enable [
          {
            key = "<leader>gg";
            action = "<cmd>LazyGit<cr>";
            options.desc = "Open lazygit";
            plugin = "lazygit.nvim";
          }
        ];
        which-key.settings.spec = [
          {
            __unkeyed-1 = "<leader>g";
            group = "Git";
            icon = "";
          }
          {
            __unkeyed-1 = "<leader>gt";
            group = "Toggle";
          }
        ];
        telescope.keymaps = {
          "<leader>gc" = {
            action = "git_commits";
            options.desc = "Git commits";
          };
          "<leader>gb" = {
            action = "git_branches";
            options.desc = "Git branches";
          };
          "<leader>gs" = {
            action = "git_status";
            options.desc = "Git status";
          };
          "<leader>gf" = {
            action = "git_files";
            options.desc = "Find files";
          };
        };
      };
      keymaps = [
        {
          key = "<leader>gBl";
          action = mkRaw "require('gitsigns').blame_line";
          options.desc = "Blame line";
        }
        {
          key = "<leader>gBb";
          action = mkRaw "require('gitsigns').blame";
          options.desc = "Blame";
        }
        {
          key = "<leader>gl";
          action = "<cmd>Git log<cr>";
          options.desc = "Log";
        }
        {
          key = "<leader>gf";
          action = "<cmd>Git fetch<cr>";
          options.desc = "Fetch";
        }
        {
          key = "<leader>gp";
          action = "<cmd>Git pull<cr>";
          options.desc = "Pull";
        }
        {
          key = "<leader>gP";
          action = "<cmd>Git push<cr>";
          options.desc = "Push";
        }
        {
          key = "<leader>gg";
          action = "<cmd>Git<cr>";
          options.desc = "Status";
        }
        {
          key = "<leader>gC";
          action = "<cmd>Git commit<cr>";
          options.desc = "Commit";
        }
        {
          key = "<leader>gr";
          action = "<cmd>Git rebase -i<cr>";
          options.desc = "Interactive rebase";
        }
        {
          key = "<leader>gd";
          action = "<cmd>Git difftool<cr>";
          options.desc = "Difftool";
        }
        {
          key = "<leader>gD";
          action = "<cmd>Gdiffsplit<cr>";
          options.desc = "Diff";
        }
        {
          key = "<leader>gm";
          action = "<cmd>Gmergetool<cr>";
          options.desc = "Merge tool";
        }
        {
          key = "<leader>gh";
          action = mkRaw "require('gitsigns').preview_hunk";
          options.desc = "Preview hunk";
        }
        {
          key = "<leader>gtb";
          action = mkRaw "require('gitsigns').toggle_current_line_blame";
          options.desc = "Toggle current line blame";
        }
        {
          key = "<leader>gtw";
          action = mkRaw "require('gitsigns').toggle_word_diff";
          options.desc = "Toggle word diff";
        }
        {
          key = "<leader>gw";
          action = mkRaw "require('telescope').extensions.git_worktree.git_worktree";
          options.desc = "Git worktrees";
        }
        {
          key = "<leader>gW";
          action = mkRaw "require('telescope').extensions.git_worktree.create_git_worktree";
          options.desc = "Create git worktree";
        }
      ];
    };
  };
}
