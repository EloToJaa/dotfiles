{
  pkgs,
  host,
  ...
}: {
  networking = {
    hostName = "${host}";
    networkmanager.enable = true;
    nameservers = ["192.168.0.31" "1.1.1.1"];
    firewall = {
      enable = true;
      allowedTCPPorts = [22 80 443 59010 59011];
      allowedUDPPorts = [59010 59011];
    };
  };

  services.mullvad-vpn.enable = true;
  services.mullvad-vpn.package = pkgs.mullvad-vpn;
  /*
    Required to get DNS working with mullvad.
  * https://discourse.nixos.org/t/connected-to-mullvadvpn-but-no-internet-connection/35803/15
  */
  networking.resolvconf.enable = false;

  environment.systemPackages = with pkgs; [
    networkmanagerapplet
  ];
}
