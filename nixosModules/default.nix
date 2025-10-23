{
  # flake.nixosModules = {
  #   base = import ./base;
  #   core = import ./core;
  #   homelab = import ./homelab;
  # };
  imports = [
    ./../settings.nix
    ./base
    ./core
    ./homelab
  ];
}
