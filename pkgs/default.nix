{
  perSystem = {pkgs, ...}: {
    packages = import ./pkgs.nix {inherit pkgs;};
  };
}
