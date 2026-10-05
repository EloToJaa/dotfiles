{lib, ...}: {
  imports = [../../nixosModules/server.nix];

  # The VM profile supplies GRUB; do not also enable Limine Secure Boot.
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

  modules.homelab = {
    nginx = {
      enable = true;
      group = "nginx";
    };
    matrix = {
      enable = true;
      serverName = "elotoja.com";
      endpointDomain = "matrix.elotoja.com";
    };
  };

  # Reuse the existing encrypted ACME credential; provision its age key separately.
  sops = {
    age.keyFile = lib.mkForce "/var/lib/sops-nix/key.txt";
    age.generateKey = false;
  };

  # Nixbot integration point: import/enable the user's module here after merging it.
  # No nixbot service or flake dependency is defined until that integration exists.
}
