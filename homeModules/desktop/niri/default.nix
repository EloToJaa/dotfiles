{lib, ...}: {
  options.modules.desktop.niri = {
    enable = lib.mkEnableOption "Enable niri";
  };
  imports = [
    ./binds.nix
    ./niri.nix
    ./settings.nix
    ./spawn.nix
    ./window-rules.nix
  ];
}
