{ pkgs, ... }: 
{
  programs.bat = {
    enable = true;
    config = {
      pager = "less -FR";
      theme = "Catppuccin Mocha";
    };
    extraPackages = with pkgs.bat-extras; [
      batman
      batpipe
      batgrep
      # batdiff
    ];
  };
}
