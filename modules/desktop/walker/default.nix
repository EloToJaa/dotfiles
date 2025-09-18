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
      providers = {
        default = [
          "desktopapplications"
          "menus"
        ];
        empty = ["desktopapplications"];
        prefixes = [
          {
            provider = "providerlist";
            prefix = ";";
          }
          {
            provider = "files";
            prefix = "/";
          }
          {
            provider = "symbols";
            prefix = ",";
          }
          {
            provider = "unicode";
            prefix = ".";
          }
          {
            provider = "todo";
            prefix = "@";
          }
          {
            provider = "calc";
            prefix = "=";
          }
          {
            provider = "websearch";
            prefix = "!";
          }
          {
            provider = "runner";
            prefix = ":";
          }
        ];
      };
      keybinds = {
        next = "ctrl j";
        previous = "ctrl k";
        close = "ctrl q";
        quick_activate = ["ctrl 1" "ctrl 2" "ctrl 3" "ctrl 4" "ctrl 5"];
      };
    };
    elephant.config.providers = {
      websearch.entries = [
        {
          name = "Google";
          prefix = "";
          default = true;
          url = "https://www.google.com/search?q=%TERM%";
        }
        {
          name = "YouTube";
          prefix = "y";
          default = false;
          url = "https://www.google.com/search?q=%TERM%";
        }
      ];
    };
  };
}
