{
  pkgs,
  variables,
  ...
}: {
  services = {
    xserver = {
      enable = true;
      videoDrivers = ["amdgpu"];
      xkb.layout = "${variables.keyboardLayout}";
    };

    displayManager.autoLogin = {
      enable = true;
      user = "${variables.username}";
    };
    libinput = {
      enable = true;
      # mouse = {
      #   accelProfile = "flat";
      # };
    };
  };
  # To prevent getting stuck at shutdown
  systemd.extraConfig = "DefaultTimeoutStopSec=10s";
}
