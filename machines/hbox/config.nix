{lib, ...}: {
  imports = [
    ../../nixosModules/server.nix
    ../../nixosModules/vm.nix
  ];

  settings.dns = ["1.1.1.1" "9.9.9.9"];
  modules.shared.nix-builder.client = {
    enable = true;
    machines = [
      {
        hostName = "100.71.230.21";
        sshUser = "nix-ssh";
        protocol = "ssh-ng";
        systems = ["x86_64-linux"];
        maxJobs = 6;
        speedFactor = 10;
        supportedFeatures = ["benchmark" "big-parallel" "kvm" "nixos-test"];
      }
    ];
  };
  programs.ssh = {
    knownHosts.worker = {
      hostNames = ["100.71.230.21"];
      publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILLbbQR4PR1/VWC3oGs0uISBG8jpxuzox8X88B/mnGXv";
    };
    extraConfig = ''
      Host 100.71.230.21
        ConnectTimeout 10
    '';
  };
  networking = {
    networkmanager.enable = lib.mkForce false;
    useNetworkd = true;
    useDHCP = false;
  };

  modules.homelab = {
    nixbot.enable = true;
    nginx.enable = true;
    matrix.enable = true;
  };
}
