{variables, ...}: {
  programs.lazygit = {
    enable = true;
    settings = {
      git = {
        paging = {
          colorArgs = "always";
          pager = "delta --dark --paging=never";
        };
      };
    };
  };
  catppuccin.lazygit = {
    enable = true;
    flavor = "${variables.catppuccin.flavor}";
    accent = "${variables.catppuccin.accent}";
  };
}
