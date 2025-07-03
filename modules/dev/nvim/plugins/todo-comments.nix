{config, ...}: let
  inherit (config.lib.nixvim) mkRaw;
in {
  programs.nixvim = {
    plugins.todo-comments = {
      enable = true;
    };
    keymaps = [
      {
        key = "]t";
        action = mkRaw "function() require('todo-comments').jump_next() end";
        desc = "Next todo comment";
      }
      {
        key = "[t";
        action = mkRaw "function() require('todo-comments').jump_prev() end";
        desc = "Previous todo comment";
      }
    ];
  };
}
