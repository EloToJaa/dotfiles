{inputs, ...}: {
  perSystem = {
    config,
    pkgs,
    ...
  }: {
    packages = import ./pkgs.nix {
      inherit pkgs;
      inherit (inputs) pyproject-build-systems pyproject-nix uv2nix yamtrack-src;
    };
    checks = config.packages;
  };
}
