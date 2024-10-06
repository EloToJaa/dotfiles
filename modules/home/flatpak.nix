{ inputs, ... }: 
{
  imports = [ inputs.nix-flatpak.homeManagerModules.nix-flatpak ];
  services.flatpak = {
    enabled = true;
    packages = [
      { appId = "io.github.zen_browser.zen"; origin = "flathub"; }
    ];
  };
}
