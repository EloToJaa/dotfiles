{
  systems = ["x86_64-linux"];
  perSystem = {...}: {
    # oh-my-posh = pkgs.callPackage ./oh-my-posh {};
  };
}
