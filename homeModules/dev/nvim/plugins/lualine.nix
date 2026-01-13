{
  lib,
  config,
  ...
}: let
  inherit (config.lib.nixvim) mkRaw;
  cfg = config.modules.dev.nvim.plugins.lualine;
in {
  options.modules.dev.nvim.plugins.lualine = {
    enable = lib.mkEnableOption "Enable lualine";
  };
  config = lib.mkIf cfg.enable {
    programs.nixvim.plugins.lualine = {
      enable = true;
      settings = {
        options = {
          section_separators = {
            left = "";
            right = "";
          };
          component_separators = {
            left = "";
            right = "";
          };
        };
        sections = {
          lualine_a = [
            {
              __unkeyed-1 = "mode";
              separator = {
                left = "";
                right = "";
              };
            }
          ];
          lualine_x =
            [
              "encoding"
              "fileformat"
              "filetype"
            ]
            ++ lib.optionals config.modules.dev.nvim.plugins.opencode.enable [
              {__unkeyed-1 = mkRaw "require('opencode').statusline";}
            ];
          lualine_z = [
            {
              __unkeyed-1 = "location";
              separator = {
                left = "";
                right = "";
              };
            }
          ];
        };
      };
    };
  };
}
