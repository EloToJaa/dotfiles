{
  perSystem = {pkgs, ...}: {
    packages = {
      btca = pkgs.callPackage ./btca {};
    };
  };
}
