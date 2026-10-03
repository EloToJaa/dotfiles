{lib, ...}: {
  options.modules.base = {
    enable = lib.mkEnableOption "Enable base module";
  };
  imports = [
    ./bash.nix
    ./bootloader.nix
    ./duo
    ./hardware.nix
    ./initrd.nix
    ./network.nix
    ./program.nix
    ./sops.nix
    ./ssh.nix
    ./sudo.nix
    ./system.nix
    ./user.nix
  ];
}
