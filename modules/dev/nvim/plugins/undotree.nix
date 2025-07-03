{
  programs.nixvim = {
    plugins.undotree.enable = true;
    keymaps = [
      {
        mode = "n";
        key = "<leader>u";
        action = "UndotreeToggle";
        options.desc = "Undotree";
      }
    ];
  };
}
