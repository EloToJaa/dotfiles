{
  programs.nixvim.plugins = {
    yazi = {
    enable = true;
    settings = {
      enable_mouse_support = true;
      open_for_directories = true;
    };
  };
    lz-n.keymaps = {
      action = "<cmd>Yazi<CR>";
      key = "<leader>fv";
      options.desc = "Open Yazi";
      plugin = "yazi.nvim";
      };
  };
}
