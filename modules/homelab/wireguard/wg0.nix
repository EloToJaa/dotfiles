{config, ...}: {
  networking.wg-quick.interfaces = let
    server_ip = "193.32.127.69";
  in {
    wg0 = {
      # IP address of this machine in the *tunnel network*
      address = [
        "10.73.69.202/32"
        "fc00:bbbb:bbbb:bb01::a:45c9/128"
      ];

      # To match firewall allowedUDPPorts (without this wg
      # uses random port numbers).
      listenPort = 51820;

      # Path to the private key file.
      privateKeyFile = config.sops.secrets."mullvad/vpn-key".path;

      dns = ["10.64.0.1"];

      peers = [
        {
          publicKey = "C3jAgPirUZG6sNYe4VuAgDEYunENUyG34X42y+SBngQ=";
          allowedIPs = ["0.0.0.0/0"];
          endpoint = "${server_ip}:51820";
          persistentKeepalive = 25;
        }
      ];

      postUp = ''
        iptables -I OUTPUT ! -o %i -m mark ! --mark $(wg show %i fwmark) -m addrtype ! --dst-type LOCAL -j REJECT && ip6tables -I OUTPUT ! -o %i -m mark ! --mark $(wg show %i fwmark) -m addrtype ! --dst-type LOCAL -j REJECT
      '';

      preDown = ''
        iptables -I OUTPUT ! -o %i -m mark ! --mark $(wg show %i fwmark) -m addrtype ! --dst-type LOCAL -j REJECT && ip6tables -I OUTPUT ! -o %i -m mark ! --mark $(wg show %i fwmark) -m addrtype ! --dst-type LOCAL -j REJECT
      '';
    };
  };
}
