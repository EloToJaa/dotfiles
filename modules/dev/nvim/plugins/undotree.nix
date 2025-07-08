{
  programs.nixvim.plugins = {
    undotree.enable = true;
    lz-n.keymaps = [
      {
        mode = "n";
        key = "<leader>U";
        action = "UndotreeToggle";
        options.desc = "Undotree";
        plugin = "undotree";
      }
    ];
  };
}
