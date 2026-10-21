{lib, ...}: {
  options.modules.desktop = {
    enable = lib.mkEnableOption "Enable desktop module";
    mainMod = lib.mkOption {
      type = lib.types.str;
      default = "SUPER";
      description = "The main modifier key";
    };
  };
  imports = [
    ./dms-shell # DankMaterialShell
    ./hyprland # window manager
    ./niri
    ./scripts # personal scripts
    ./wallpapers
    ./wezterm
    ./artcraft.nix # ArtCraft creative apps
    ./audacious.nix # music player
    ./bluetooth.nix
    ./cava.nix # audio visualizer
    ./clipboard.nix
    ./discord.nix # discord
    ./ghostty.nix
    ./gnome.nix # gnome apps
    ./helium.nix # chromium-based browser
    ./gtk.nix # gtk theme
    ./nautilus.nix # file manager
    ./notifications.nix # notifications
    ./piper-tts.nix
    ./packages.nix # other packages
    ./prismlauncher.nix
    ./remmina.nix # remote desktop client (rdp, vnc, ssh)
    ./rider.nix # jetbrains rider
    ./satty.nix # screenshot annotate tool
    ./spotify.nix # spotify client
    ./variables.nix
    ./vicinae.nix # launcher
    ./voxtype.nix # voice dictation
    ./web-apps.nix
    ./winboat.nix # remote desktop
    ./xcompose.nix # Compose sequences and emoji shortcuts
    ./xdg-mimes.nix # xdg config
    ./zen.nix
  ];
}
