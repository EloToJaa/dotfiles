{...}: {
  imports = [
    ./hyprland # window manager
    ./scripts # personal scripts
    ./swaync # notification deamon
    ./wallpapers
    ./waybar # status bar
    ./wezterm
    ./audacious.nix # music player
    ./cava.nix # audio visualizer
    ./discord.nix # discord
    ./ghostty.nix
    ./gnome.nix # gnome apps
    ./gtk.nix # gtk theme
    ./kitty.nix
    ./nemo.nix # file manager
    ./packages.nix # other packages
    ./qbittorrent.nix
    ./rofi.nix # launcher
    ./spicetify.nix # spotify client
    ./swayosd.nix # brightness / volume wiget
    ./waypaper.nix # wallpaper picker
    ./xdg-mimes.nix # xdg config
    ./zen.nix
  ];
}
