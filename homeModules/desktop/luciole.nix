{
  lib,
  config,
  settings,
  ...
}: let
  cfg = config.modules.desktop.luciole;
in {
  options.modules.desktop.luciole = {
    enable = lib.mkEnableOption "Enable Luciole file manager";
  };
  config = lib.mkIf cfg.enable {
    programs.luciole = {
      enable = true;
      settings = {
        schema_version = 1;
        browser = {
          view_mode = "list";
          density = "compact";
          show_hidden = true;
          activation_mode = "double_click";
          show_permanent_deletion = true;
          sidebar_width = 220;
          terminal_command = settings.terminal;
          thumbnail_policy = "local";
        };
      };
    };

    programs.noctalia.settings.theme.templates = lib.mkIf config.modules.desktop.noctalia-shell.enable {
      enable_builtin_templates = true;
      builtin_ids = ["luciole"];
    };
  };
}
