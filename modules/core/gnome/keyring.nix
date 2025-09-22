{pkgs, ...}: {
  programs = {
    seahorse.enable = true;
    dconf.enable = true;
  };

  services = {
    gnome = {
      gnome-keyring.enable = true;
      tinysparql.enable = true;
    };
    gvfs.enable = true;
    logind.extraConfig = ''
      # don't shutdown when power button is short-pressed
      HandlePowerKey=ignore
    '';
    polkit.enable = true;

    dbus = {
      enable = true;
      packages = with pkgs.unstable; [
        gcr
        gnome-settings-daemon
      ];
    };
  };
}
