{
  lib,
  config,
  ...
}: let
  cfg = config.modules.home.nvim.plugins.trouble;
in {
  options.modules.home.nvim.plugins.trouble = {
    enable = lib.mkEnableOption "Enable trouble";
  };
  config = lib.mkIf cfg.enable {
    programs.nixvim.plugins = {
      trouble = {
        enable = true;
        settings.focus = true;
      };
      lz-n.keymaps = [
        {
          action = "<cmd>Trouble diagnostics toggle<CR>";
          key = "<leader>dw";
          options.desc = "Open trouble workspace diagnostics";
          plugin = "trouble.nvim";
        }
        {
          action = "<cmd>Trouble diagnostics toggle filter.buf=0<CR>";
          key = "<leader>dd";
          options.desc = "Open trouble document diagnostics";
          plugin = "trouble.nvim";
        }
        {
          action = "<cmd>Trouble quickfix toggle<CR>";
          key = "<leader>dq";
          options.desc = "Open trouble quickfix list";
          plugin = "trouble.nvim";
        }
        {
          action = "<cmd>Trouble loclist toggle<CR>";
          key = "<leader>dl";
          options.desc = "Open trouble location list";
          plugin = "trouble.nvim";
        }
        {
          action = "<cmd>Trouble todo toggle<CR>";
          key = "<leader>dt";
          options.desc = "Open todos in trouble";
          plugin = "trouble.nvim";
        }
      ];
      which-key.settings.spec = [
        {
          __unkeyed-1 = "<leader>d";
          group = "Trouble";
          icon = "";
        }
      ];
    };
  };
}
