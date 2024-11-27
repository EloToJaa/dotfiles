{...}: {
  imports = [
    ./gnome
    ./bluetooth.nix
    ./network.nix
    ./pipewire.nix
    ./security.nix
    ./services.nix
    ./virtualization.nix
    ./wayland.nix
    ./xserver.nix
  ];
}
