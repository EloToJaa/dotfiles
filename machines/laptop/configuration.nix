{config, ...}: let
  inherit (config.settings) username;
in {
  imports = [
    ./config.nix
    {
      home-manager.users.${username}.imports = [
        ./home.nix
      ];
    }
  ];
}
