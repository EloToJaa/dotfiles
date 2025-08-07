{
  pkgs,
  variables,
  ...
}: {
  programs.bat = {
    enable = true;
    package = pkgs.unstable.bat;

    config = {
      pager = "less -FR";
    };

    extraPackages = with pkgs.unstable.bat-extras; [
      # batman
      batpipe
      batgrep
      # batdiff
    ];
  };
  catppuccin.bat = {
    enable = true;
    flavor = variables.catppuccin.flavor;
  };
}
