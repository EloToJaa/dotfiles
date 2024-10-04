{ pkgs, ... }: 
{
  # home.packages = (with pkgs; [ brave ]);
  services.flatpak.packages = [
    { appId = "com.brave.Browser"; origin = "flathub"; }
  ];
}
