{inputs, ...}: {
  imports = [
    inputs.catppuccin.homeModules.catppuccin
    inputs.nix-index-database.homeModules.nix-index
    inputs.nixvim.homeModules.nixvim
    inputs.zen-browser.homeModules.default

    inputs.dankcalendar.homeModules.dank-calendar

    ./ai
    ./cybersec
    ./desktop
    ./dev
    ./home
  ];
}
