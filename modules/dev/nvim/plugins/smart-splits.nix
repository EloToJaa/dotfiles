{config, ...}: let
  mkRaw = config.lib.nixvim.mkRaw;
in {
  programs.nixvim = {
    plugins.smart-splits = {
      enable = true;
      settings = {
        ignored_buftypes = [
          "nofile"
          "quickfix"
          "prompt"
        ];
        ignored_filetypes = [
          "NvimTree"
        ];
        default_amount = 3;
        at_edge = "wrap";
        float_win_behavior = "previous";
        move_cursor_same_row = false;
        cursor_follows_swapped_bufs = false;
        resize_mode = {
          quit_key = "<ESC>";
          resize_keys = [
            "h"
            "j"
            "k"
            "l"
          ];
          silent = false;
          hooks = {
            on_enter = null;
            on_leave = null;
          };
        };
        ignore_events = [
          "BufEnter"
          "WinEnter"
        ];
        multiplexer_integration = null;
        disable_multiplexer_nav_when_zoomed = true;
        kitty_password = null;
        log_level = "info";
      };
    };
    keymaps = [
      {
        mode = "n";
        key = "<A-h>";
        action = mkRaw "function() require('smart-splits').resize_left() end";
        options.desc = "Resize left";
      }
      {
        mode = "n";
        key = "<A-j>";
        action = mkRaw "function() require('smart-splits').resize_down() end";
        options.desc = "Resize down";
      }
      {
        mode = "n";
        key = "<A-k>";
        action = mkRaw "function() require('smart-splits').resize_up() end";
        options.desc = "Resize up";
      }
      {
        mode = "n";
        key = "<A-l>";
        action = mkRaw "function() require('smart-splits').resize_right() end";
        options.desc = "Resize right";
      }
      {
        mode = "n";
        key = "<C-h>";
        action = mkRaw "function() require('smart-splits').move_cursor_left() end";
        options.desc = "Move cursor left";
      }
      {
        mode = "n";
        key = "<C-j>";
        action = mkRaw "function() require('smart-splits').move_cursor_down() end";
        options.desc = "Move cursor down";
      }
      {
        mode = "n";
        key = "<C-k>";
        action = mkRaw "function() require('smart-splits').move_cursor_up() end";
        options.desc = "Move cursor up";
      }
      {
        mode = "n";
        key = "<C-l>";
        action = mkRaw "function() require('smart-splits').move_cursor_right() end";
        options.desc = "Move cursor right";
      }
      {
        mode = "n";
        key = "<C-\\>";
        action = mkRaw "function() require('smart-splits').move_cursor_previous() end";
        options.desc = "Move cursor previous";
      }
      {
        mode = "n";
        key = "<leader><leader>h";
        action = mkRaw "function() require('smart-splits').swap_buf_left() end";
        options.desc = "Swap buffer left";
      }
      {
        mode = "n";
        key = "<leader><leader>j";
        action = mkRaw "function() require('smart-splits').swap_buf_down() end";
        options.desc = "Swap buffer down";
      }
      {
        mode = "n";
        key = "<leader><leader>k";
        action = mkRaw "function() require('smart-splits').swap_buf_up() end";
        options.desc = "Swap buffer up";
      }
      {
        mode = "n";
        key = "<leader><leader>l";
        action = mkRaw "function() require('smart-splits').swap_buf_right() end";
        options.desc = "Swap buffer right";
      }
    ];
  };
}
