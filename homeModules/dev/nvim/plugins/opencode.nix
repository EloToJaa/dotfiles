{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (config.lib.nixvim) mkRaw;
  inherit (config.settings) isServer;
  cfg = config.modules.dev.nvim.plugins.opencode;
in {
  options.modules.dev.nvim.plugins.opencode = {
    enable = lib.mkEnableOption "Enable opencode";
  };
  config = lib.mkIf (cfg.enable && config.modules.dev.opencode.enable) {
    home.packages = with pkgs.unstable; [lsof];
    programs.nixvim = {
      keymaps = [
        {
          mode = ["n" "x"];
          key = "<leader>oa";
          action = mkRaw "function() require('opencode').ask('@this: ', { submit = true }) end";
          options.desc = "Ask opencode";
        }
        {
          mode = ["n" "x"];
          key = "<leader>ox";
          action = mkRaw "function() require('opencode').select() end";
          options.desc = "Execute opencode action…";
        }
        {
          mode = ["n" "t"];
          key = "<leader>oo";
          action = mkRaw "function() require('opencode').toggle() end";
          options.desc = "Toggle opencode";
        }
        {
          mode = ["n" "x"];
          key = "go";
          action = mkRaw "function() return require('opencode').operator('@this ') end";
          options.expr = true;
          options.desc = "Add range to opencode";
        }
        {
          mode = "n";
          key = "goo";
          action = mkRaw "function() return require('opencode').operator('@this ') .. '_' end";
          options.expr = true;
          options.desc = "Add line to opencode";
        }
        {
          mode = "n";
          key = "<S-C-u>";
          action = mkRaw "function() require('opencode').command('session.half.page.up') end";
          options.desc = "opencode half page up";
        }
        {
          mode = "n";
          key = "<S-C-d>";
          action = mkRaw "function() require('opencode').command('session.half.page.down') end";
          options.desc = "opencode half page down";
        }
        {
          mode = "n";
          key = "+";
          action = "<C-a>";
          options.desc = "Increment";
          options.noremap = true;
        }
        {
          mode = "n";
          key = "-";
          action = "<C-x>";
          options.desc = "Decrement";
          options.noremap = true;
        }
      ];
      plugins = {
        opencode = {
          enable = true;
          settings = {
            provider.enabled = "terminal";
          };
        };
        snacks = {
          enable = true;
          settings = {
            input.enable = true;
            picker.enable = true;
            terminal.enable = true;
          };
        };
      };
    };
  };
}
