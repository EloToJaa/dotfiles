{
  config,
  inputs,
  self,
  ...
}: {
  flake.nixosConfigurations = let
    inherit (inputs.nixpkgs.lib) nixosSystem;
    inherit (config.settings) username;
    specialArgs = {inherit inputs self host;};
    system = "x86_64-linux";
    host = "server";
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
