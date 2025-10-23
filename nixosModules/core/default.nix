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
    ./network.nix
    ./security.nix
    ./steam.nix
    ./virtualization.nix
    ./wayland.nix
    ./xserver.nix
  ];
}
