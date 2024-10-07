{ pkgs, ... }: 
{
  programs.btop = {
    enable = true;

    catppuccin = {
      enable = true;
      flavor = "mocha";
    };
    
    settings = {
      theme_background = false;
      update_ms = 500;
    };
  };

  home.packages = (with pkgs; [ nvtopPackages.amd ]);
}
