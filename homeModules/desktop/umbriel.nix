{
  lib,
  config,
  settings,
  ...
}: let
  inherit (settings) keyboardLayout;
  cfg = config.modules.desktop.umbriel;
  umbriel = config.programs.umbriel.package;
in {
  options.modules.desktop.umbriel = {
    enable = lib.mkEnableOption "Enable umbriel";
  };

  config = lib.mkIf cfg.enable {
    # Umbriel is designed around the Noctalia shell, which it launches via its systemd user service
    modules.desktop.noctalia-shell.enable = lib.mkDefault true;

    programs.umbriel = {
      enable = true;
      # A user config replaces the packaged one, so include it to keep the default keybinds
      # (including the Noctalia launcher and media keys) and the Noctalia window and layer rules.
      settings = {
        include.files = ["${umbriel}/share/umbriel/config.toml"];
        input.keyboard = {
          layout = keyboardLayout;
          # Same as niri: Alt+Caps switches layout and Menu is the Compose key.
          options = "grp:alt_caps_toggle,compose:menu";
          numlock_toggle = true;
        };
      };
    };
  };
}
