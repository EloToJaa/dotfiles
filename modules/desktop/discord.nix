{
  pkgs,
  variables,
  ...
}: {
  home.packages = with pkgs; [
    (discord.override {
      withVencord = false;
    })
    # webcord-vencord
  ];

  xdg.configFile."Vencord/themes/custom.css".text =
    /*
    css
    */
    ''
      /**
       * @name Catppuccin
       * @author winston#0001
       * @authorId 505490445468696576
       * @version 0.2.0
       * @description 🎮 Soothing pastel theme for Discord
       * @website https://github.com/catppuccin/discord
       * @invite r6Mdz5dpFc
       * **/

      @import url("https://catppuccin.github.io/discord/dist/catppuccin-${variables.catppuccin.flavor}.theme.css");
    '';
}
