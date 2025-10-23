{
  flake.nixosModules = {
    settings = import ./../settings;
    base = import ./base;
    core = import ./core;
    homelab = import ./homelab;
  };
}
