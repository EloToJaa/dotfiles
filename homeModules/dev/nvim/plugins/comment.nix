{
  config,
  lib,
  ...
}: let
  cfg = config.modules.dev.nvim.plugins.comment;
in {
  options.modules.dev.nvim.plugins.comment = {
    enable = lib.mkEnableOption "Enable comment";
  };
  config = lib.mkIf cfg.enable {
    programs.nixvim.plugins = {
      ts-context-commentstring = {
        enable = true;
        settings.languages.c = {
          __default = "// %s";
          __multiline = "/* %s */";
        };
      };
      comment = {
        enable = true;
        settings.pre_hook = config.lib.nixvim.mkRaw ''
          require("ts_context_commentstring.integrations.comment_nvim").create_pre_hook()
        '';
      };
    };
  };
}
