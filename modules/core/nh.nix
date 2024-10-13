{ pkgs, variables, ... }: 
{
  programs.nh = {
    enable = true;
    clean = {
      enable = true;
      extraArgs = "--keep-since 7d --keep 5";
    };
    flake = "/home/${variables.username}/dotfiles";
  };

  environment.systemPackages = with pkgs; [
    nix-output-monitor
    nvd
  ];
}
