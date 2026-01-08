{
  config,
  lib,
  ...
}: let
  inherit (config.lib.nixvim) mkRaw;
  cfg = config.modules.home.nvim.plugins.todo-comments;
in {
  options.modules.home.nvim.plugins.todo-comments = {
    enable = lib.mkEnableOption "Enable todo-comments";
  };
  config = lib.mkIf cfg.enable {
    programs.nixvim = {
      plugins.todo-comments = {
        enable = true;
      };
      keymaps = [
        {
          mode = "n";
          key = "]t";
          action = mkRaw "function() require('todo-comments').jump_next() end";
          options.desc = "Next todo comment";
        }
        {
          mode = "n";
          key = "[t";
          action = mkRaw "function() require('todo-comments').jump_prev() end";
          options.desc = "Previous todo comment";
        }
      ];
    };
  };
}
