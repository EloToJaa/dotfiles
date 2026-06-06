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
    ./config.nix
    ../../homeModules/vars.nix
    {
      home-manager.users.${username}.imports = [
        ./home.nix
      ];
    }
  ];
  clan.core.deployment.requireExplicitUpdate = true;
}
