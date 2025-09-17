{inputs, ...}: {
  imports = [
    inputs.walker.homeManagerModules.default
  ];

  programs.walker = {
    enable = true;
    runAsService = true;
    # theme = null;

    # All options from the config.toml can be used here.
    config = {
      placeholders."default".input = "Example";
      providers.prefixes = [
        {
          provider = "websearch";
          prefix = "+";
        }
        {
          provider = "providerlist";
          prefix = "_";
        }
      ];
      keybinds.quick_activate = ["F1" "F2" "F3"];
    };
  };
}
