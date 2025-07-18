{
  networking.nat = {
    enable = true;
    # Use "ve-*" when using nftables instead of iptables
    internalInterfaces = ["ve-+"];
    externalInterface = "enp1s0";
    # Lazy IPv6 connectivity for the container
    enableIPv6 = true;
  };
}
