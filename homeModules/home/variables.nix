{
  config,
  host,
  lib,
  ...
}: let
  inherit (config.settings) uid;
  cfg = config.modules.home;
in {
  config = lib.mkIf cfg.enable {
    home.sessionVariables = {
      SSH_AUTH_SOCK = "/run/user/${toString uid}/keyring/ssh";
      NIXPKGS_ALLOW_UNFREE = "1";
      NIXPKGS_ALLOW_INSECURE = "1";
      NH_FLAKE = "${config.home.homeDirectory}/Projects/dotfiles";
      HOST = host;
    };
  };
}
