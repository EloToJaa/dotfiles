{
  lib,
  config,
  ...
}: let
  inherit (config.settings) username uid ssh;
in {
  # Unlike server/config.nix, do not import the heavyweight server profile.
  imports = [../../nixosModules];

  settings.isServer = true;
  system.stateVersion = "26.05";
  nix.settings.experimental-features = ["nix-command" "flakes"];
  networking = {
    useNetworkd = true;
    useDHCP = false;
    nameservers = ["1.1.1.1" "9.9.9.9"];
  };
  systemd.network.networks."10-uplink" = {
    matchConfig.Name = "en* eth*";
    networkConfig.DHCP = "ipv4";
    networkConfig.IPv6AcceptRA = true;
  };
  services.resolved.enable = true;
  services.fstrim.enable = true;
  users.users.${username} = {
    isNormalUser = true;
    inherit uid;
    extraGroups = ["wheel"];
    hashedPassword = "!";
    openssh.authorizedKeys.keys = [ssh.keys.user];
  };
  # Key-only administration; srvos provides passwordless wheel sudo.
  services.openssh.settings = {
    PasswordAuthentication = false;
    KbdInteractiveAuthentication = false;
    PermitRootLogin = "no";
  };

  modules.homelab = {
    enable = true;
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
    defaultSopsFile = ../../secrets/secrets.yaml;
    age.keyFile = "/var/lib/sops-nix/key.txt";
    age.generateKey = false;
  };

  # Nixbot integration point: import/enable the user's module here after merging it.
  # No nixbot service or flake dependency is defined until that integration exists.
}
