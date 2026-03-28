{inputs, ...}: {
  imports = [
    inputs.catppuccin.homeModules.catppuccin
    inputs.nix-index-database.homeModules.nix-index
    inputs.nixvim.homeModules.nixvim
    inputs.hyprland.homeManagerModules.default
    inputs.zen-browser.homeModules.default

    inputs.dms.homeModules.dank-material-shell
    inputs.dms.homeModules.niri
    inputs.danksearch.homeModules.dsearch

    ./cybersec
    ./desktop
    ./dev
    ./home
  ];
}
