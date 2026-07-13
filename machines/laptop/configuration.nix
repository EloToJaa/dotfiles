{
  config,
  inputs,
  ...
}: let
  inherit (config.settings) username;
in {
  _module.args.host = "laptop";
  imports = [
    inputs.srvos.nixosModules.desktop
    ./../../nixosModules/laptop.nix
    ../../homeModules/vars.nix
    {
      home-manager.users.${username}.imports = [
        ../../homeModules/laptop.nix
      ];
    }
  ];
  clan.core.deployment.requireExplicitUpdate = true;
}
