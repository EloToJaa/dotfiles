{
  pkgs,
  variables,
  ...
}: {
  virtualisation.docker = {
    # enable = true;
    rootless = {
      enable = true;
      setSocketVariable = true;
    };
  };
  users.users.${variables.username} = {
    extraGroups = ["docker"];
    linger = true;
  };
  security.wrappers = {
    docker-rootlesskit = {
      owner = "root";
      group = "root";
      capabilities = "cap_net_bind_service+ep";
      source = "${pkgs.rootlesskit}/bin/rootlesskit";
    };
  };
  programs.zsh = {
    shellAliases = {
      d = "docker";
      ld = "lazydocker";
      dc = "docker compose";
      dcu = "docker compose up -d --force-recreate --remove-orphans";
      dcd = "docker compose down --remove-orphans";
    };
  };
}
