{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.modules.core;
in {
  options.modules.core.mullvad = {
    enable = lib.mkEnableOption "Enable mullvad";
  };
  config = lib.mkIf cfg.enable {
    services.mullvad-vpn = {
      inherit (cfg.mullvad) enable;
      package = pkgs.unstable.mullvad-vpn;
    };
    /*
      Required to get DNS working with mullvad.
    * https://discourse.nixos.org/t/connected-to-mullvadvpn-but-no-internet-connection/35803/15
    */
    networking.resolvconf.enable = false;

    environment.systemPackages = with pkgs.unstable; [
      networkmanagerapplet
    ];
  };
}
