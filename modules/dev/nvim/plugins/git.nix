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
      ];
    };
    keymaps = [
      {
        key = "<leader>gb";
        action = "<cmd>Git blame<cr>";
        options.desc = "Blame";
      }
      {
        key = "<leader>gl";
        action = "<cmd>Git log<cr>";
        options.desc = "Blame";
      }
      {
        key = "<leader>gh";
        action = mkRaw "require('gitsigns').preview_hunk";
        options.desc = "Preview hunk";
      }
      {
        key = "<leader>gt";
        action = mkRaw "require('gitsigns').toggle_current_line_blame";
        options.desc = "Preview hunk";
      }
    ];
  };
}
