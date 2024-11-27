{
  programs = {
    seahorse.enable = true;
    dconf.enable = true;
  };

  services = {
    gnome.gnome-keyring.enable = true;
  };
}
