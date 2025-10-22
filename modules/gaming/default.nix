{config, ...}: let
  inherit (config.modules.settings) username;
in {
  home-manager.users.${username}.imports = [
    ./packages.nix
  ];

  imports = [
    ./steam.nix
  ];
}
