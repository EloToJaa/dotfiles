{...}: {
  imports = [
    ./gnome
    ./android.nix
    ./bluetooth.nix
    ./network.nix
    ./pipewire.nix
    ./security.nix
    ./virtualization.nix
    ./wayland.nix
    ./xserver.nix
  ];
}
