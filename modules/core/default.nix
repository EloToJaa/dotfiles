{ inputs, nixpkgs, self, username, host, ...}:
{
  imports = [
    ./gnome
    ./bootloader.nix
    ./hardware.nix
    ./network.nix
    ./nh.nix
    ./pipewire.nix
    ./program.nix
    ./security.nix
    ./services.nix
    ./system.nix
    ./user.nix
    ./virtualization.nix
    ./wayland.nix
    ./xserver.nix
  ];
}
