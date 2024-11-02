{...}: {
  programs = {
    oh-my-posh = {
      enable = true;

      #enableZshIntegration = true;
      #enableNushellIntegration = true;
    };
    zsh.initExtra = ''
      eval "$(oh-my-posh init zsh --config ~/.config/oh-my-posh/config.toml)"
    '';
  };

  xdg.configFile."oh-my-posh/config.toml".source = ./config.toml;
}
