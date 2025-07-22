{
  pkgs,
  variables,
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

  environment.systemPackages = with pkgs; [
    nix-update
    nix-output-monitor
    nvd
  ];
}
