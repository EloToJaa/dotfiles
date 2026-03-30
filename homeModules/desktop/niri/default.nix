{lib, ...}: {
  options.modules.desktop.niri = {
    enable = lib.mkEnableOption "Enable niri";
  };
  imports = [
    ./binds.nix
    ./settings.nix
    ./spawn.nix
    ./window-rules.nix
    ./workspaces.nix
  ];
}
