{pkgs, ...}: {
  programs.hyprland.enable = true;
  xdg.portal = {
    enable = true;
    wlr.enable = true;
    xdgOpenUsePortal = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-hyprland
      pkgs.xdg-desktop-portal-gtk
    ];
  };

  boot.initrd.kernelModules = ["amdgpu"];

  environment.systemPackages = with pkgs; [
    xwaylandvideobridge
  ];
}
