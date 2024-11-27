{...}: {
  imports = [
    ./bootloader.nix
    ./hardware.nix
    ./network.nix
    ./nfs.nix
    ./nh.nix
    ./program.nix
    ./system.nix
    ./user.nix
  ];
}
