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
    ./hyprland # window manager
    ./niri
    ./scripts # personal scripts
    ./swaync # notification deamon
    ./wallpapers
    ./waybar # status bar
    ./wezterm
    ./audacious.nix # music player
    ./bluetooth.nix
    ./cava.nix # audio visualizer
    ./clipboard.nix
    ./discord.nix # discord
    ./dms-shell.nix # DankMaterialShell
    ./ghostty.nix
    ./gnome.nix # gnome apps
    ./gtk.nix # gtk theme
    ./hyprlock.nix # lock screen
    ./nemo.nix # file manager
    ./packages.nix # other packages
    ./rider.nix # jetbrains rider
    ./satty.nix # screenshot annotate tool
    ./spotify.nix # spotify client
    ./swayosd.nix # brightness / volume wiget
    ./variables.nix
    ./vicinae.nix # launcher
    ./waypaper.nix # wallpaper picker
    ./wlogout.nix # logout screen
    ./xdg-mimes.nix # xdg config
    ./zen.nix
  ];
}
