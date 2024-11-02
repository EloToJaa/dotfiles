{pkgs, ...}: {
  home.packages = with pkgs; [oh-my-posh];

  programs = {
    zsh.initExtra = ''
      eval "$(oh-my-posh init zsh --config ~/.config/oh-my-posh/config.toml)"
    '';
    nushell = {
      extraEnv = ''
        oh-my-posh init nu --print | save ~/.config/nushell/oh-my-posh.nu --force
      '';
      extraConfig = ''
        source ~/.config/nushell/oh-my-posh.nu
      '';
    };
  };

  xdg.configFile."oh-my-posh/config.toml".source = ./config.toml;
}
