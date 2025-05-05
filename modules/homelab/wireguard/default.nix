{...}: {
  imports = [./wg0.nix];
  sops.secrets = {
    "mullvad/vpn-key" = {};
  };
  networking.firewall.allowedUDPPorts = [51820];
}
