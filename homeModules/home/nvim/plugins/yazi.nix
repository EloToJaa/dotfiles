{
  lib,
  config,
  ...
}: let
  cfg = config.modules.home.nvim.plugins.yazi;
in {
  options.modules.home.nvim.plugins.yazi = {
    enable = lib.mkEnableOption "Enable yazi";
  };
  config = lib.mkIf (cfg.enable && config.modules.home.yazi.enable) {
    programs.nixvim = {
      plugins = {
        yazi = {
          enable = true;
          settings = {
            enable_mouse_support = true;
            open_for_directories = true;
          };
        };
        lz-n.keymaps = [
          {
            action = "<cmd>Yazi<CR>";
            key = "<leader>fv";
            options.desc = "Open Yazi";
            plugin = "yazi.nvim";
          }
        ];
      };
      globals.loaded_netrwPlugin = 1;
    };
  };
}
