{ inputs, ... }: 
{
  imports = [ inputs.nix-flatpak.homeManagerModules.nix-flatpak ];
  services.flatpak = {
    packages = [
      { appId = "io.github.zen_browser.zen"; origin = "flathub"; }
    ];
  };
}
