{config, ...}: let
  inherit (config.settings) username;
in {
  imports = [
    ./../settings.nix
    ./base
    ./core
    ./homelab
    {
      home-manager.users.${username}.imports = [
        ../homeModules
      ];
    }
  ];
}
