{pkgs, ...}: {
  security.polkit.enable = true;

  services.hyprpolkitagent = {
    enable = true;
    package = pkgs.unstable.hyprpolkitagent;
  };
}
