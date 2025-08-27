{inputs, ...}: {
  imports = [
    inputs.nix-index-database.nixosModules.nix-index
    ./bootloader.nix
    ./docker.nix
    ./hardware.nix
    ./network.nix
    ./nfs.nix
    ./nh.nix
    ./program.nix
    ./sops.nix
    ./ssh.nix
    ./system.nix
    ./user.nix
  ];
}
