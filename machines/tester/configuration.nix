{config, ...}: let
  inherit (config.settings) username;
in {
  _module.args.host = "tester";
  imports = [
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
