{
  config,
  host,
  lib,
  ...
}: let
  cfg = config.modules.home;
in {
  config = lib.mkIf cfg.enable {
    home.sessionVariables = {
      SSH_AUTH_SOCK = "/run/user/${config.modules.settings.uid}/keyring/ssh";
      NIXPKGS_ALLOW_UNFREE = "1";
      NIXPKGS_ALLOW_INSECURE = "1";
      NH_FLAKE = "${config.home.homeDirectory}/Projects/dotfiles";
      HOST = host;
    };
  };
}
