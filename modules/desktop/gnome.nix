{pkgs, ...}: {
  home.packages = with pkgs.unstable; [
    evince # pdf
    file-roller # archive
    gnome-text-editor # gedit
  ];

  services.kdeconnect = {
    enable = false;
    package = pkgs.unstable.kdePackages.kdeconnect-kde;
  };

  dconf.settings = {
    "org/gnome/TextEditor" = {
      custom-font = "CaskaydiaCove Nerd Font 15";
      highlight-current-line = true;
      indent-style = "space";
      restore-session = false;
      show-grid = false;
      show-line-numbers = true;
      show-right-margin = false;
      style-scheme = "builder-dark";
      style-variant = "dark";
      tab-width = "uint32 4";
      use-system-font = false;
      wrap-text = false;
    };
  };
}
