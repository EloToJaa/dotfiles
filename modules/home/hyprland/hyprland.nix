{ inputs, pkgs, ...}: 
{
  home.packages = with pkgs; [
    swww
    inputs.hypr-contrib.packages.${pkgs.system}.grimblast
    hyprpicker
    inputs.hyprmag.packages.${pkgs.system}.hyprmag
    grim
    slurp
    wl-clip-persist
    (cliphist.overrideAttrs (old: { doCheck = false; }))
    # inputs.nixpkgs-master.packages.${pkgs.system}.cliphist
    wf-recorder
    glib
    wayland
    direnv
  ];
  
  systemd.user.targets.hyprland-session.Unit.Wants = [ "xdg-desktop-autostart.target" ];
  wayland.windowManager.hyprland = {
    enable = true;
    xwayland = {
      enable = true;
      # hidpi = true;
    };
    # enableNvidiaPatches = false;
    systemd.enable = true;
  };
}
