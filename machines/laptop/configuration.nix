{self, ...}: {
  nixpkgs.pkgs = self.inputs.nixpkgs.legacyPackages.x86_64-linux;
  networking.hostName = "laptop";
  imports = [
    ./config.nix
    # {
    #   home-manager.users.${username}.imports = [
    #     ./home.nix
    #   ];
    # }
  ];
}
