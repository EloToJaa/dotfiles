{pkgs, ...}: {
  services.mullvad-vpn = {
    enable = true;
    package = pkgs.mullvad-vpn;
  };
  /*
    Required to get DNS working with mullvad.
  * https://discourse.nixos.org/t/connected-to-mullvadvpn-but-no-internet-connection/35803/15
  */
  networking.resolvconf.enable = false;

  environment.systemPackages = with pkgs; [
    networkmanagerapplet
  ];
}
