{
  config,
  lib,
  ...
}: let
  cfg = config.modules.dev.nvim;
in {
  config = lib.mkIf cfg.enable {
    programs.nixvim = {
      globals = {
        mapleader = " ";
        maplocalleader = "\\";
      };

      keymaps = [
        {
          mode = "n";
          key = "<leader>rp";
          action = ":lua require('precognition').peek()<CR>";
          options.desc = "Peek recognition";
        }
        {
          mode = "n";
          key = "<leader>nh";
          action = ":nohl<CR>";
          options.desc = "Clear search highlights";
        }
        {
          mode = "n";
          key = "<leader>+";
          action = "<C-a>";
          options.desc = "Increment number";
        }
        {
          mode = "n";
          key = "<leader>-";
          action = "<C-x>";
          options.desc = "Decrement number";
        }
        {
          mode = "n";
          key = "<leader>v";
          action = "<C-w>s";
          options.desc = "Split window vertically";
        }
        {
          mode = "n";
          key = "<leader>s";
          action = "<C-w>v";
          options.desc = "Split window horizontally";
        }
        {
          mode = "n";
          key = "<leader>e";
          action = "<C-w>=";
          options.desc = "Make splits equal size";
        }
        {
          mode = "n";
          key = "<leader>x";
          action = "<cmd>close<CR>";
          options.desc = "Close current split";
        }
        {
          mode = "n";
          key = "<leader>t";
          action = "<cmd>tabnew<CR>";
          options.desc = "Open new tab";
        }
        {
          mode = "n";
          key = "<leader>q";
          action = "<cmd>tabclose<CR>";
          options.desc = "Close current tab";
        }
        {
          mode = "n";
          key = "<leader>]";
          action = "<cmd>tabn<CR>";
          options.desc = "Go to next tab";
        }
        {
          mode = "n";
          key = "<leader>[";
          action = "<cmd>tabp<CR>";
          options.desc = "Go to previous tab";
        }
        {
          mode = "n";
          key = "<leader>b";
          action = "<cmd>tabnew %<CR>";
          options.desc = "Open current buffer in new tab";
        }
        {
          mode = "n";
          key = "<leader>0";
          action = ":tabnext 10<CR>";
          options.desc = "Go to tab 10";
        }
        {
          mode = "n";
          key = "<leader>1";
          action = ":tabnext 1<CR>";
          options.desc = "Go to tab 1";
        }
        {
          mode = "n";
          key = "<leader>2";
          action = ":tabnext 2<CR>";
          options.desc = "Go to tab 2";
        }
        {
          mode = "n";
          key = "<leader>3";
          action = ":tabnext 3<CR>";
          options.desc = "Go to tab 3";
        }
        {
          mode = "n";
          key = "<leader>4";
          action = ":tabnext 4<CR>";
          options.desc = "Go to tab 4";
        }
        {
          mode = "n";
          key = "<leader>5";
          action = ":tabnext 5<CR>";
          options.desc = "Go to tab 5";
        }
        {
          mode = "n";
          key = "<leader>6";
          action = ":tabnext 6<CR>";
          options.desc = "Go to tab 6";
        }
        {
          mode = "n";
          key = "<leader>7";
          action = ":tabnext 7<CR>";
          options.desc = "Go to tab 7";
        }
        {
          mode = "n";
          key = "<leader>8";
          action = ":tabnext 8<CR>";
          options.desc = "Go to tab 8";
        }
        {
          mode = "n";
          key = "<leader>9";
          action = ":tabnext 9<CR>";
          options.desc = "Go to tab 9";
        }
        {
          mode = "n";
          key = "<M-n>";
          action = "<cmd>cnext<CR>";
          options.desc = "Next quickfix item";
        }
        {
          mode = "n";
          key = "<M-p>";
          action = "<cmd>cprev<CR>";
          options.desc = "Previous quickfix item";
        }
        {
          mode = "n";
          key = "<M-q>";
          action = "<cmd>cdo del<CR>";
          options.desc = "Delete quickfix item";
        }
        {
          mode = "n";
          key = "<M-l>";
          action = "<cmd>copen<CR>";
          options.desc = "Open quickfix list";
        }
      ];
    };
  };
}
