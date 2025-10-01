{
  programs.nixvim.plugins = {
    undotree.enable = true;
    lz-n.keymaps = [
      {
        mode = "n";
        key = "<leader>u";
        action = "<cmd>UndotreeToggle<CR>";
        options.desc = "Undotree";
        plugin = "undotree";
      }
    ];
  };
}
