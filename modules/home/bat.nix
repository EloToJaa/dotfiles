{ pkgs, ... }: 
{
  programs.bat = {
    enable = true;

    catppuccin = {
      enable = true;
      flavor = "mocha";
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
