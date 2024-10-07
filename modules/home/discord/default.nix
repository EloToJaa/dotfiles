{ pkgs, ... }: 
{
  home.packages = with pkgs; [
    # discord
    # (discord.override {
    #  withVencord = true;
    # })
    webcord-vencord
  ];
  xdg.configFile."Vencord/themes/catppuccin.theme.css".source = ./catppuccin.css;
}
