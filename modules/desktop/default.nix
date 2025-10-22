{lib, ...}: {
  options.modules.desktop = {
    enable = lib.mkEnableOption "Enable desktop module";
  };
  imports = [
    ./hyprland # window manager
    ./scripts # personal scripts
    ./swaync # notification deamon
    ./wallpapers
    ./waybar # status bar
    # ./wezterm
    ./audacious.nix # music player
    ./bluetooth.nix
    ./cava.nix # audio visualizer
    ./clipboard.nix
    ./discord.nix # discord
    ./ghostty.nix
    ./gnome.nix # gnome apps
    ./gtk.nix # gtk theme
    ./nemo.nix # file manager
    ./packages.nix # other packages
    # ./rider.nix # jetbrains rider
    ./spotify.nix # spotify client
    ./swayosd.nix # brightness / volume wiget
    ./vicinae.nix # launcher
    ./waypaper.nix # wallpaper picker
    ./xdg-mimes.nix # xdg config
    ./zen.nix
  ];
}
