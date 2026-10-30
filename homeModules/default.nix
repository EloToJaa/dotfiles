{inputs, ...}: {
  imports = [
    inputs.catppuccin.homeModules.catppuccin
    inputs.nix-index-database.homeModules.nix-index
    inputs.nixvim.homeModules.nixvim
    inputs.zen-browser.homeModules.default

    inputs.dms.homeModules.dank-material-shell
    inputs.dms-plugin-registry.homeModules.default
    inputs.dankcalendar.homeModules.dank-calendar
    inputs.noctalia.homeModules.default

    ./ai
    ./cybersec
    ./desktop
    ./dev
    ./home
  ];
}
