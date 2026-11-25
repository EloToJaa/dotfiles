{inputs, ...}: {
  perSystem = {
    config,
    pkgs,
    ...
  }: {
    packages = import ./pkgs.nix {
      inherit pkgs;
      inherit (inputs) pyproject-build-systems pyproject-nix uv2nix;
      unifi-mcp-src = inputs.unifi-mcp;
      yamtrack-src = inputs.yamtrack;
    };
    checks = config.packages;
  };
}
