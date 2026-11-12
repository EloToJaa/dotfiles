{
  inputs,
  config,
  ...
}: let
  inherit (config.settings) username;
in {
  imports = [
    inputs.nixos-wsl.nixosModules.default
    ./config.nix
    ../../homeModules/vars.nix
    {
      home-manager.users.${username}.imports = [../../homeModules/server.nix];
    }
  ];

  _module.args.host = "wsl";
  nixpkgs.hostPlatform = "x86_64-linux";
}
