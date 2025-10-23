{
  systems = ["x86_64-linux"];
  perSystem = {pkgs, ...}: {
    # oh-my-posh = pkgs.callPackage ./oh-my-posh {};
  };
}
