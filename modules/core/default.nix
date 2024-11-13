{...}: {
  imports = [
    ./gnome
    ./bluetooth.nix
    ./bootloader.nix
    ./hardware.nix
    ./network.nix
    ./nfs.nix
    ./nh.nix
    ./pgadmin.nix
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
