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
    ./pipewire.nix
    ./security.nix
    ./virtualization.nix
    ./wayland.nix
    ./xserver.nix
  ];
}
