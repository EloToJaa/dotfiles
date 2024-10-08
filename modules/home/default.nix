{inputs, variables, host, ...}: {
  imports = [
    ./discord                         # discord
    ./hyprland                        # window manager
    ./p10k/p10k.nix
    ./scripts/scripts.nix             # personal scripts
    ./swaync/swaync.nix               # notification deamon
    ./waybar                          # status bar
    ./zsh                             # shell
    ./audacious.nix                   # music player
    ./bat.nix                         # better cat command
    ./btop.nix                        # resouces monitor 
    ./catppuccin.nix
    ./cava.nix                        # audio visualizer
    ./fastfetch.nix                   # fetch tool
    ./fzf.nix                         # fuzzy finder
    ./git.nix                         # version control
    ./gnome.nix                       # gnome apps
    ./gtk.nix                         # gtk theme
    ./kitty.nix                       # terminal
    ./lazygit.nix
    ./nvim.nix                        # neovim editor
    ./packages.nix                    # other packages
    ./rofi.nix                        # launcher
    ./spicetify.nix                   # spotify client
    ./starship.nix                    # shell prompt
    ./swayosd.nix                     # brightness / volume wiget
    ./tmux.nix                        # terminal multiplexer
    ./vscodium.nix                    # vscode fork
    ./xdg-mimes.nix                   # xdg config
    ./zen.nix
  ];
}
