{
  config,
  lib,
  ...
}: let
  cfg = config.modules.home.nvim.plugins.supermaven;
in {
  options.modules.home.nvim.plugins.supermaven = {
    enable = lib.mkEnableOption "Enable supermaven";
  };
  config = lib.mkIf cfg.enable {
    programs.nixvim.plugins.supermaven = {
      enable = true;
      settings = {
        keymaps = {
          accept_suggestion = "<C-Tab>";
          clear_suggestion = "<C-]>";
          accept_word = null;
        };
        color = {
          suggestion_color = "#ffffff";
          cterm = 244;
        };
        log_level = "info";
        disable_inline_completion = false;
        disable_keymaps = false;
        condition = config.lib.nixvim.mkRaw ''
          function() return false end
        '';
      };
    };
  };
}
