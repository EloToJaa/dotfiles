{...}: {
  services = {
    gvfs.enable = true;
    dbus.enable = true;
  };
  services.logind.extraConfig = ''
    # don't shutdown when power button is short-pressed
    HandlePowerKey=ignore
  '';
}
