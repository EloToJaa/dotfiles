{config, ...}: let
  inherit (config.settings) username;
in {
  _module.args.host = "miro";
  imports = [
    ./config.nix
    ../../homeModules/vars.nix
    {
      home-manager.users.${username}.imports = [
        ../../homeModules/server.nix
      ];
    }
  ];
  clan.core.deployment.requireExplicitUpdate = true;
}
