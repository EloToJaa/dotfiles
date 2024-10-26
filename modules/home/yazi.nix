{
  pkgs,
  inputs,
  variables,
  ...
}: {
  home.packages = [pkgs.exiftool];
  programs.yazi = {
    enable = true;

    package = inputs.yazi.packages.${pkgs.system}.default;

    catppuccin = {
      enable = true;
      flavor = "${variables.catppuccin.flavor}";
    };

    enableZshIntegration = true;

    settings = {
      manager = {
        layout = [1 4 3];
        sort_by = "alphabetical";
        sort_sensitive = false;
        sort_reverse = false;
        sort_dir_first = true;
        linemode = "mtime";
        show_hidden = true;
        show_symlink = true;
        scrolloff = 8;
      };
      preview = {
        tab_size = 2;
        max_width = 600;
        max_height = 900;
      };
    };
  };
}
