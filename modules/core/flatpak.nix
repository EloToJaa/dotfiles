{ ... }: 
{
  services.flatpak = {
    enable = true;
    # packages = [
    #   { appId = "com.brave.Browser"; origin = "flathub"; }
    # ];
  };
}
