{config, ...}: let
  inherit (config.lib.nixvim) mkRaw;
in {
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
}
