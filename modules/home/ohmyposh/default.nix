{pkgs, ...}: {
  home.packages = with pkgs; [oh-my-posh];

  programs = {
    zsh.initContent = ''
      eval "$(${pkgs.oh-my-posh}/bin/oh-my-posh init zsh --config ~/.config/oh-my-posh/config.toml)"
    '';
  };

  xdg.configFile."oh-my-posh/config.toml".source = ./config.toml;
}
