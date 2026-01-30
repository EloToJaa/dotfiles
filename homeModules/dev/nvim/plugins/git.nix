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
        lz-n.keymaps = [
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
      };
      keymaps = [
        {
          key = "<leader>gB";
          action = mkRaw "require('gitsigns').blame_line";
          options.desc = "Blame line";
        }
        {
          key = "<leader>gb";
          action = mkRaw "require('gitsigns').blame";
          options.desc = "Blame";
        }
        {
          key = "<leader>gl";
          action = "<cmd>Git log<cr>";
          options.desc = "Log";
        }
        {
          key = "<leader>gs";
          action = "<cmd>Git<cr>";
          options.desc = "Status";
        }
        {
          key = "<leader>gc";
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
