{
  inputs,
  pkgs,
  variables,
  ...
}: let
  themePkg = pkgs.callPackage ./pkgs/theme.nix {};
  inherit (variables.catppuccin) flavor;
in {
  imports = [
    inputs.walker.homeManagerModules.default
  ];

  xdg.configFile = {
    "walker/themes/${flavor}.toml".source = "${themePkg}/${flavor}.toml";
    "walker/themes/${flavor}.css".source = "${themePkg}/${flavor}.css";
  };

  programs.walker = {
    enable = true;
    runAsService = true;
    # theme = null;

    config = {
      theme = flavor;
      search.placeholder = "Example";
      ui.fullscreen = true;
      list = {
        height = 200;
      };
      websearch.prefix = "?";
      # switcher.prefix = "/";
    };
  };
}
