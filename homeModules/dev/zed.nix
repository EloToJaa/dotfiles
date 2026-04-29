{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.modules.dev.zed;
in {
  options.modules.dev.zed = {
    enable = lib.mkEnableOption "Enable Zed editor";
  };

  config = lib.mkIf cfg.enable {
    programs.zed-editor = {
      enable = true;
      package = pkgs.unstable.zed-editor;
      installRemoteServer = true;

      mutableUserSettings = false;
      mutableUserKeymaps = false;

      extensions = [
        "nix"
        "catppuccin"
        "toml"
        "json"
        "lua"
        "rust"
        "markdown-oxide"
      ];

      extraPackages = with pkgs.unstable; [
        nixd
        rust-analyzer
        prettierd
        stylua
        clang
      ];

      userSettings = {
        # theme is set by catppuccin home-manager module
        buffer_font_family = "JetBrains Mono";
        ui_font_family = "JetBrains Mono";
        vim_mode = true;
        format_on_save = "on";
      };
    };
  };
}
