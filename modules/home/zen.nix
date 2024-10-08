{ inputs, system, ... }: 
{
  imports = [
    inputs.nix-flatpak.homeManagerModules.nix-flatpak
    inputs.zen-browser.packages."${system}".specific
  ];
  services.flatpak = {
    enable = true;
    packages = [
      { appId = "io.github.zen_browser.zen"; origin = "flathub"; }
    ];
  };
}
