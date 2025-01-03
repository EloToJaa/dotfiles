{
  pkgs,
  variables,
  ...
}: {
  programs.btop = {
    enable = true;

    settings = {
      theme_background = false;
      update_ms = 500;
      rounded_corners = false;
    };
  };
  catppuccin.btop = {
    enable = true;
    flavor = "${variables.catppuccin.flavor}";
  };

  home.packages = with pkgs; [nvtopPackages.amd];
}
