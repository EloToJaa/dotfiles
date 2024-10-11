{ pkgs, ... }: 
{
  home.packages = with pkgs; [
    oh-my-posh
  ];

  xdg.configFile."oh-my-posh/config.toml".source = ./config.toml;
}
