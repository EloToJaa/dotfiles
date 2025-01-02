{variables, ...}: {
  # https://github.com/catppuccin/lazygit/blob/main/themes/mocha/blue.yml
  programs.lazygit = {
    enable = true;
    settings = {
      git = {
        paging = {
          colorArgs = "always";
          pager = "delta --dark --paging=never";
        };
      };
      theme = {
        activeBorderColor = [
          "#89b4fa"
          "bold"
        ];
        inactiveBorderColor = [
          "#a6adc8"
        ];
        optionsTextColor = [
          "#89b4fa"
        ];
        selectedLineBgColor = [
          "#313244"
        ];
        cherryPickedCommitBgColor = [
          "#45475a"
        ];
        cherryPickedCommitFgColor = [
          "#89b4fa"
        ];
        unstagedChangesColor = [
          "#f38ba8"
        ];
        defaultFgColor = [
          "#cdd6f4"
        ];
        searchingActiveBorderColor = [
          "#f9e2af"
        ];
      };
      authorColors = {
        "*" = "#b4befe";
      };
    };
  };
  # catppuccin.lazygit = {
  #   enable = true;
  #   flavor = "${variables.catppuccin.flavor}";
  #   accent = "${variables.catppuccin.accent}";
  # };
}
