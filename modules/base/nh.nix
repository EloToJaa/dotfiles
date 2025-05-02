{
  pkgs,
  variables,
  config,
  host,
  ...
}: {
  programs.nh = {
    enable = true;
    clean = {
      enable = true;
      extraArgs = "--keep-since 7d --keep 5";
    };
    flake = "/home/${variables.username}/Projects/dotfiles";
  };

  home.sessionVariables = {
    NH_FLAKE = "${config.home.homeDirectory}/Projects/dotfiles";
    HOST = host;
  };

  environment.systemPackages = with pkgs; [
    nix-output-monitor
    nvd
  ];
}
