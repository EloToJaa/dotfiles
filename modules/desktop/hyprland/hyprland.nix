{pkgs, ...}: {
  home.packages = with pkgs.unstable; [
    swww
    grimblast
    hyprprop
    hyprpicker
    grim
    slurp
    wf-recorder
    glib
    wayland
    wleave
  ];

  systemd.user.targets.hyprland-session.Unit.Wants = ["xdg-desktop-autostart.target"];
  wayland.windowManager.hyprland = {
    enable = true;
    package = null;
    portalPackage = null;
    xwayland = {
      enable = true;
      # hidpi = true;
    };
    # enableNvidiaPatches = false;
    systemd.enable = true;
  };
}
