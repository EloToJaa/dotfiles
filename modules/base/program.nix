{...}: {
  programs = {
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
      # pinentryFlavor = "";
    };
    nix-ld.enable = true;
    zsh.enable = true;
    nushell.enable = true;
  };

  security.rtkit.enable = true;
}
