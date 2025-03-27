{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    v4l-utils
  ];

  boot.kernelModules = ["v4l2loopback"];
}
