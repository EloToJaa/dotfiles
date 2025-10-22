{
  lib,
  config,
  ...
}: let
  inherit (config.modules.settings) keyboardLayout username;
  cfg = config.modules.core.xserver;
in {
  options.modules.core.xserver = {
    enable = lib.mkEnableOption "Enable xserver module";
  };
  config = lib.mkIf cfg.enable {
    services = {
      xserver = {
        enable = true;
        videoDrivers = ["amdgpu"];
        xkb.layout = keyboardLayout;
      };

      displayManager.autoLogin = {
        enable = true;
        user = username;
      };
      libinput = {
        enable = true;
      };
    };
  };
}
