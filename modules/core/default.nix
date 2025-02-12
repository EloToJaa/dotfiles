{...}: {
  imports = [
    ./gnome
    ./adb.nix
    ./bluetooth.nix
    ./network.nix
    ./pipewire.nix
    ./security.nix
    ./user.nix
    ./virtualization.nix
    ./wayland.nix
    ./xserver.nix
  ];
}
