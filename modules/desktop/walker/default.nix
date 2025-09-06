{inputs, ...}: {
  imports = [
    inputs.walker.homeManagerModules.default
  ];

  programs.walker = {
    enable = true;
    runAsService = true;
    # theme = null;

    config = {
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
