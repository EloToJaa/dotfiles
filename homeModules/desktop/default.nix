{lib, ...}: {
  options.modules.desktop.enable = lib.mkEnableOption "Enable desktop module";
  imports = [
    ./scripts # personal scripts
    ./wallpapers
    ./wezterm
    ./artcraft.nix # ArtCraft creative apps
    ./audacious.nix # music player
    ./bluetooth.nix
    ./cava.nix # audio visualizer
    ./chromium.nix # browser
    ./clipboard.nix
    ./discord.nix # discord
    ./ghostty.nix
    ./gnome.nix # gnome apps
    ./helium.nix # chromium-based browser
    ./gtk.nix # gtk theme
    ./nautilus.nix # file manager
    ./noctalia-shell.nix # desktop shell, launcher and clipboard history
    ./notifications.nix # notifications
    ./omnissa-horizon.nix # vdi client
    ./piper-tts.nix
    ./packages.nix # other packages
    ./prismlauncher.nix
    ./remmina.nix # remote desktop client (rdp, vnc, ssh)
    ./rider.nix # jetbrains rider
    ./satty.nix # screenshot annotate tool
    ./spotify.nix # spotify client
    ./umbriel.nix # umbriel compositor
    ./variables.nix
    ./voxtype.nix # voice dictation
    ./web-apps.nix
    ./winboat.nix # remote desktop
    ./xcompose.nix # Compose sequences and emoji shortcuts
    ./xdg-mimes.nix # xdg config
    ./zen.nix
  ];
}
