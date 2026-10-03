{
  lib,
  config,
  ...
}: let
  inherit (config.settings) keyboardLayout;
  cfg = config.modules.core.xserver;
in {
  options.modules.core.xserver = {
    enable = lib.mkEnableOption "Enable xserver module";
  };
  config = lib.mkIf (config.modules.core.enable && cfg.enable) {
    services = {
      xserver = {
        enable = true;
        videoDrivers = ["amdgpu"];
        xkb.layout = keyboardLayout;
      };

      libinput = {
        enable = true;
      };
    };
  };
}
