{ inputs, ... }: 
{
  imports = [ inputs.nix-flatpak.nixosModules.nix-flatpak ];
  services.flatpak = {
    enable = true;
    # packages = [
    #   { appId = "com.brave.Browser"; origin = "flathub"; }
    # ];
  };
}
