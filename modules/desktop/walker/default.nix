{
  inputs,
  pkgs,
  ...
}: {
  imports = [
    inputs.walker.homeManagerModules.default
  ];

  xdg.configFile = {
    "walker/themes".source = pkgs.callPackage ./theme.nix {};
  };

  programs.walker = {
    enable = true;
    runAsService = true;

    config = {
      search.placeholder = "Example";
      ui.fullscreen = true;
      list = {
        height = 200;
      };
      websearch.prefix = "?";
      theme = "mocha";
      # switcher.prefix = "/";
    };
  };
}
