{inputs, ...}: {
  imports = [
    inputs.home-manager.nixosModules.home-manager
    inputs.sops-nix.nixosModules.sops
    inputs.nix-index-database.nixosModules.nix-index
    inputs.nix-gaming.nixosModules.pipewireLowLatency
    inputs.dms.nixosModules.greeter

    ./../settings.nix
    ./base
    ./core
    ./homelab
  ];
}
