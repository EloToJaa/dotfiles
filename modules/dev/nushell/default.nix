{
  imports = [./nu.nix];
  programs = {
    atuin.enableNushellIntegration = true;
    zoxide.enableNushellIntegration = true;
    eza.enableNushellIntegration = false;
    carapace.enableNushellIntegration = true;
  };
}
