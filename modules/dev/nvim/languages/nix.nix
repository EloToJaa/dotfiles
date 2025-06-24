{
  home.packages = with pkgs; [
    alejandra
    deadnix
    statix
  ];

  programs.nixvim = {
    lsp.servers.nixd = {
      enable = true;
    };
    plugins.lint.lintersByFt = {
      nix = ["deadnix" "statix"];
    };
    plugins.conform-nvim.settings.formatters_by_ft = {
      nix = ["alejandra"];
    };
  };
}
