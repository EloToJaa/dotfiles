{
  perSystem = {
    config,
    pkgs,
    ...
  }: {
    packages = import ./pkgs.nix {inherit pkgs;};
    checks = config.packages;
  };
}
