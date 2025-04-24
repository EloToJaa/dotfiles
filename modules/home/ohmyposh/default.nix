{pkgs, ...}: {
  home.packages = with pkgs; [oh-my-posh];

  programs = {
    zsh.initContent =
      /*
      sh
      */
      ''
        eval "$(oh-my-posh init zsh --config ~/.config/oh-my-posh/config.toml)"
      '';
    nushell = {
      extraEnv =
        /*
        nu
        */
        ''
          oh-my-posh init nu --config ~/.config/oh-my-posh/config.toml --print | save ~/.config/nushell/oh-my-posh.nu --force
        '';
      extraConfig =
        /*
        nu
        */
        ''
          source ~/.config/nushell/oh-my-posh.nu
        '';
    };
  };

  xdg.configFile."oh-my-posh/config.toml".source = ./config.toml;
}
