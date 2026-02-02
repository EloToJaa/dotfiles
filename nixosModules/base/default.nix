{lib, ...}: {
  options.modules.base = {
    enable = lib.mkEnableOption "Enable base module";
  };
  imports = [
    ./bash.nix
    ./bootloader.nix
    ./docker.nix
    ./duo.nix
    ./hardware.nix
    ./index.nix
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
