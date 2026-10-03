{lib, ...}: {
  options.modules.core = {
    enable = lib.mkEnableOption "Enable core module";
  };
  imports = [
    ./adb.nix
    ./audio.nix
    ./bluetooth.nix
    ./camera.nix
    ./gnome.nix
    ./mullvad.nix
    ./network.nix
    ./plymouth.nix
    ./program.nix
    ./printing.nix
    ./security.nix
    ./steam.nix
    ./virtualization.nix
    ./wayland
    ./xserver.nix
  ];
}
