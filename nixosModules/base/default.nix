{lib, ...}: {
  options.modules.base = {
    enable = lib.mkEnableOption "Enable base module";
  };
  imports = [
    ./bash.nix
    ./bootloader.nix
    ./btrfs.nix
    ./btop.nix
    ./catppuccin.nix
    ./docker.nix
    ./duo
    ./hardware.nix
    ./index.nix
    ./initrd.nix
    ./network.nix
    ./nfs.nix
    ./nh.nix
    ./program.nix
    ./plymouth.nix
    ./sops.nix
    ./ssh.nix
    ./system.nix
    ./user.nix
  ];
}
