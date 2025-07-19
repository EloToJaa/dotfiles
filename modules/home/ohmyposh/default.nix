{pkgs, ...}: {
  # home.packages = with pkgs; [oh-my-posh];
  home.packages = with pkgs; [callPackage ../../../pkgs/oh-my-posh.nix {}];

  programs = {
    zsh.initContent =
      /*
      sh
      */
      ''
        eval "$(${pkgs.oh-my-posh}/bin/oh-my-posh init zsh --config ~/.config/oh-my-posh/config.toml)"
      '';
    nushell = {
      extraEnv =
        /*
        nu
        */
        ''
          ${pkgs.oh-my-posh}/bin/oh-my-posh init nu --config ~/.config/oh-my-posh/config.toml --print | save ~/.config/nushell/oh-my-posh.nu --force
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
