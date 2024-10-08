{ pkgs, variables, ... }: 
{
  programs.btop = {
    enable = true;

    catppuccin = {
      enable = true;
      flavor = "${variables.catppuccin.flavor}";
    };
    
    settings = {
      theme_background = false;
      update_ms = 500;
    };
  };

  home.packages = (with pkgs; [ nvtopPackages.amd ]);
}
