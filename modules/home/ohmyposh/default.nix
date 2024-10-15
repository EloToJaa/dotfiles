{ pkgs, ... }: 
{
  programs.oh-my-posh = {
    enable = true;
    enableZshIntegration = true;
  };

  xdg.configFile."oh-my-posh/config.toml".source = ./config.toml;
}
