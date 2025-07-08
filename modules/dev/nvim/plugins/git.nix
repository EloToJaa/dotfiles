{config, ...}: let
  inherit (config.lib.nixvim) mkRaw;
in {
  programs.nixvim = {
    plugins = {
      lazygit.enable = true;
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
          change_directory_command = "z";
          clear_jumps_on_change = true;
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
        key = "<leader>gb";
        action = mkRaw "require('gitsigns').blame_line";
        options.desc = "Blame line";
      }
      {
        key = "<leader>gB";
        action = mkRaw "require('gitsigns').blame";
        options.desc = "Blame";
      }
      {
        key = "<leader>gl";
        action = "<cmd>Git log<cr>";
        options.desc = "Log";
      }
      {
        key = "<leader>gd";
        action = "<cmd>Gdiffsplit<cr>";
        options.desc = "Diff";
      }
      {
        key = "<leader>gD";
        action = "<cmd>Git difftool<cr>";
        options.desc = "Difftool";
      }
      {
        key = "<leader>gh";
        action = mkRaw "require('gitsigns').preview_hunk";
        options.desc = "Preview hunk";
      }
      {
        key = "<leader>gtb";
        action = mkRaw "require('gitsigns').toggle_current_line_blame";
        options.desc = "Preview hunk";
      }
      {
        key = "<leader>gtw";
        action = mkRaw "require('gitsigns').toggle_word_diff";
        options.desc = "Preview hunk";
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
}
