{
  config,
  inputs,
  self,
  ...
}: {
  flake.nixosConfigurations = let
    inherit (inputs.nixpkgs.lib) nixosSystem;
    inherit (config.settings) username;
    inherit (self) outputs;
    specialArgs = {inherit inputs outputs self host;};
    system = "x86_64-linux";
    host = "tester";
  in {
    "${host}" = nixosSystem {
      inherit specialArgs system;
      modules = [
        ./hardware-configuration.nix
        ./config.nix
        {
          home-manager.users.${username}.imports = [
            ./home.nix
          ];
        }
      ];
    };
  };
}
