{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.modules.dev.nvim.plugins.yazi;
in {
  options.modules.dev.nvim.plugins.yazi = {
    enable = lib.mkEnableOption "Enable yazi";
  };
  config = lib.mkIf (cfg.enable && config.modules.home.yazi.enable) {
    programs.nixvim = {
      dependencies.yazi.package = pkgs.unstable.yazi;
      plugins = {
        yazi = {
          enable = true;
          settings = {
            enable_mouse_support = true;
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
