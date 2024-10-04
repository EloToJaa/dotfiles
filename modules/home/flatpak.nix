{ inputs, ... }: 
{
  imports = [ inputs.nix-flatpak.homeManagerModules.default ];
  services.flatpak = {
    enable = true;
    packages = [
      { appId = "io.github.zen_browser.zen"; origin = "flathub"; }
    ];
  };
}
