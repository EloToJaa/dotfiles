{variables, ...}: {
  home.sessionVariables = {
    SSH_AUTH_SOCK = "/run/user/1000/keyring/ssh";
    NIXPKGS_ALLOW_UNFREE = "1";
    NIXPKGS_ALLOW_INSECURE = "1";
    DOCKER_HOST = "unix:///run/user/1000/docker.sock";
    FLAKE = "/home/${variables.username}/Projects/dotfiles";
  };
}
