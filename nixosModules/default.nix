{inputs, ...}: {
  imports = [
    inputs.home-manager.nixosModules.home-manager
    inputs.sops-nix.nixosModules.sops
    inputs.nix-index-database.nixosModules.nix-index
    inputs.nix-gaming.nixosModules.pipewireLowLatency
    inputs.dms.nixosModules.greeter
    inputs.niri.nixosModules.niri
    inputs.hermes-agent.nixosModules.default

    ./../settings.nix
    ./base
    ./core
    ./homelab
  ];
}
