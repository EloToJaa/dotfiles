{
  config,
  host,
  lib,
  settings,
  ...
}: let
  inherit (settings) uid dotfilesDirectory;
  cfg = config.modules.home;
in {
  config = lib.mkIf cfg.enable {
    home.sessionVariables = {
      SSH_AUTH_SOCK = "/run/user/${toString uid}/keyring/ssh";
      NIXPKGS_ALLOW_UNFREE = "1";
      NIXPKGS_ALLOW_INSECURE = "1";
      NH_FLAKE = dotfilesDirectory;
      HOST = host;
    };
  };
}
