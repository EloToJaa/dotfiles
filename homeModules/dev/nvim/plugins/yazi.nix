{
  lib,
  config,
  ...
}: let
  cfg = config.modules.dev.nvim.plugins.yazi;
  inherit (config.lib.nixvim) mkRaw;
in {
  options.modules.dev.nvim.plugins.yazi = {
    enable = lib.mkEnableOption "Enable yazi";
  };
  config = lib.mkIf (cfg.enable && config.modules.home.yazi.enable) {
    programs.nixvim = {
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
      autoCmd = [
        {
          event = "UIEnter";
          callback = mkRaw ''
            function()
              require("yazi").setup({ open_for_directories = true })
            end
          '';
        }
      ];
      globals.loaded_netrwPlugin = 1;
    };
  };
}
