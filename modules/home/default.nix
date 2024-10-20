{inputs, variables, host, ...}: {
  imports = [
    ./hyprland                        # window manager
    ./nvim                            # neovim editor
    ./ohmyposh                        # shell prompt
    ./scripts                         # personal scripts
    ./swaync                          # notification deamon
    ./wallpapers
    ./waybar                          # status bar
    ./wezterm
    ./zsh                             # shell
    ./audacious.nix                   # music player
    ./bat.nix                         # better cat command
    ./btop.nix                        # resouces monitor 
    ./catppuccin.nix
    ./cava.nix                        # audio visualizer
    ./discord.nix                     # discord
    ./fastfetch.nix                   # fetch tool
    ./fzf.nix                         # fuzzy finder
    ./git.nix                         # version control
    ./gnome.nix                       # gnome apps
    ./gtk.nix                         # gtk theme
    ./lazygit.nix
    ./nemo.nix                        # file manager
    ./packages.nix                    # other packages
    ./rofi.nix                        # launcher
    ./spicetify.nix                   # spotify client
    ./swayosd.nix                     # brightness / volume wiget
    ./vscodium.nix                    # vscode fork
    ./xdg-mimes.nix                   # xdg config
    ./zen.nix
  ];
}
