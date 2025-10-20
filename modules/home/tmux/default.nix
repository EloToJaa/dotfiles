{lib, ...}: {
  options.modules.home.tmux = {
    enable = lib.mkEnableOption "Enable tmux";
  };
  imports = [
    ./tmux.nix
    ./plugins.nix
  ];
}
