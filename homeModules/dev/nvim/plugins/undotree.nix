{
  lib,
  config,
  ...
}: let
  cfg = config.modules.dev.nvim.plugins.undotree;
in {
  options.modules.dev.nvim.plugins.undotree = {
    enable = lib.mkEnableOption "Enable undotree";
  };
  config = lib.mkIf cfg.enable {
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
  };
}
