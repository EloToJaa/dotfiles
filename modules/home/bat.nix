{
  pkgs,
  variables,
  ...
}: {
  programs.bat = {
    enable = true;

    config = {
      pager = "less -FR";
    };

    extraPackages = with pkgs.bat-extras; [
      # batman
      batpipe
      batgrep
      # batdiff
    ];
  };
  catppuccin.bat = {
    enable = true;
    flavor = "${variables.catppuccin.flavor}";
  };
}
