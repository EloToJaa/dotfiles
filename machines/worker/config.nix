{lib, ...}: {
  imports = [../../nixosModules/server.nix];

  # Keep the simple UEFI boot setup instead of the profile's Secure Boot loader.
  modules.base.bootloader.enable = lib.mkForce false;

  settings.dns = ["1.1.1.1" "9.9.9.9"];
  networking = {
    networkmanager.enable = lib.mkForce false;
    useNetworkd = true;
    useDHCP = false;
  };
  systemd.network.networks."10-uplink" = {
    matchConfig.Name = "en* eth*";
    networkConfig.DHCP = "ipv4";
    networkConfig.IPv6AcceptRA = true;
  };
}
