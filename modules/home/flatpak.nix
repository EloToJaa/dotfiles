{ inputs, ... }: 
{
  imports = [ inputs.nix-flatpak.homeManagerModules.default ];
  services.flatpak = {
    packages = [
      { appId = "io.github.zen_browser.zen"; origin = "flathub"; }
    ];
  };
}
