{lib, ...}: {
  options.modules.desktop.niri = {
    enable = lib.mkEnableOption "Enable niri";
  };
  imports = [
  ];
}
