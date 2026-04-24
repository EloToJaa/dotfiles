{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.modules.base.btop;
  inherit (config.settings) username;
in {
  options.modules.base.btop = {
    enable = lib.mkEnableOption "Enable btop with Intel GPU sysfs permissions";
  };

  config = lib.mkIf cfg.enable {
    security.wrappers.btop = {
      setuid = false;
      owner = "root";
      group = "root";
      source = lib.getExe pkgs.unstable.btop;
      capabilities = "cap_perfmon,cap_dac_read_search+ep";
    };

    home-manager.users.${username}.modules.home.btop.enable = lib.mkDefault true;
  };
}
