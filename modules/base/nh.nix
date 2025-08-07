{
  pkgs,
  variables,
  ...
}: {
  programs.nh = {
    enable = true;
    package = pkgs.unstable.nh;
    clean = {
      enable = true;
      extraArgs = "--keep-since 7d --keep 5";
    };
    flake = "/home/${variables.username}/Projects/dotfiles";
  };

  environment.systemPackages = with pkgs.unstable; [
    nix-update
    nix-output-monitor
    nvd
  ];
}
