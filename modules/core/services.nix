{ ... }: 
{
  services = {
    gvfs.enable = true;
    gnome.gnome-keyring.enable = true;
    dbus.enable = true;
    fstrim.enable = true;
    tailscale.enable = true;
    flatpak = {
      enable = true;
      services.flatpak.packages = [
        { appId = "com.brave.Browser"; origin = "flathub"; }
      ];
    };
  };
  services.logind.extraConfig = ''
    # don’t shutdown when power button is short-pressed
    HandlePowerKey=ignore
  '';
}
