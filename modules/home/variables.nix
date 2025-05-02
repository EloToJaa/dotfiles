{
  config,
  host,
  ...
}: {
  home.sessionVariables = {
    SSH_AUTH_SOCK = "/run/user/1000/keyring/ssh";
    NIXPKGS_ALLOW_UNFREE = "1";
    NIXPKGS_ALLOW_INSECURE = "1";
    NH_FLAKE = "${config.home.homeDirectory}/Projects/dotfiles";
    HOST = host;
  };
}
