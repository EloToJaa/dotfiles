{
  pkgs,
  variables,
  ...
}: {
  programs.bat = {
    enable = true;

    catppuccin = {
      enable = true;
      flavor = "${variables.catppuccin.flavor}";
    };

    config = {
      pager = "less -FR";
    };

    extraPackages = with pkgs.bat-extras; [
      batman
      batpipe
      batgrep
      # batdiff
    ];
  };
}
