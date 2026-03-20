{inputs, ...}: {
  imports = [
    inputs.catppuccin.homeModules.catppuccin
    inputs.nix-index-database.homeModules.nix-index
    inputs.nixvim.homeModules.nixvim
    inputs.hyprland.homeManagerModules.default
    inputs.zen-browser.homeModules.default
    inputs.niri-nix.homeModules.default

    ./cybersec
    ./desktop
    ./dev
    ./home
  ];
}
