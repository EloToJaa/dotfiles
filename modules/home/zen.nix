{ inputs, pkgs, ... }: 
{
  imports = [
    inputs.nix-flatpak.homeManagerModules.nix-flatpak
  ];
  home.packages = [
    inputs.zen-browser.packages.${pkgs.system}.default
  ];
  services.flatpak = {
    enable = true;
    packages = [
      { appId = "io.github.zen_browser.zen"; origin = "flathub"; }
    ];
  };
}
