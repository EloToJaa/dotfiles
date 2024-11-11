{...}: {
  #home.packages = [pkgs.hyprlock];
  programs.hyprlock = {
    enable = true;
    settings = {
      general = {
        hideCursor = true;
        noFadeIn = false;
        grace = 0;
        disableLoadingBar = false;
      };

      background = [
        {
          monitor = "";
          path = "${../wallpapers/wallpapers/others/forest.jpg}";
          blurPasses = 1;
          contrast = 0.8916;
          brightness = 0.8172;
          vibrancy = 0.1696;
          vibrancyDarkness = 0.0;
        }
      ];

      label = [
        {
          # Time
          monitor = "";
          text = ''cmd[update:1000] echo "$(date +"%k:%M")"'';
          color = "rgba(235, 219, 178, 0.9)";
          fontSize = 111;
          fontFamily = "JetBrainsMono NF Bold";
          position = "0, 270";
          halign = "center";
          valign = "center";
        }
        {
          # Day
          monitor = "";
          text = ''cmd[update:1000] echo "- $(date +"%A, %B %d") -"'';
          color = "rgba(235, 219, 178, 0.9)";
          fontSize = 20;
          fontFamily = "Maple Mono";
          position = "0, 160";
          halign = "center";
          valign = "center";
        }
        {
          # User
          monitor = "";
          text = "  $USER";
          color = "rgba(235, 219, 178, 0.9)";
          fontSize = 16;
          fontFamily = "Maple Mono";
          position = "0, -230";
          halign = "center";
          valign = "center";
        }
      ];

      shape = [
        {
          # User-box
          monitor = "";
          size = "350, 50";
          color = "rgba(225, 225, 225, 0.2)";
          rounding = 15;
          borderSize = 0;
          borderColor = "rgba(255, 255, 255, 0)";
          rotate = 0;
          position = "0, -230";
          halign = "center";
          valign = "center";
        }
      ];

      input-field = [
        {
          monitor = "";
          size = "350, 50";
          outlineThickness = 0;
          rounding = 15;
          dotsSize = 0.25;
          dotsSpacing = 0.4;
          dotsCenter = true;
          outerColor = "rgba(255, 255, 255, 0.2)";
          innerColor = "rgba(225, 225, 225, 0.2)";
          color = "rgba(235, 219, 178, 0.9)";
          fontColor = "rgba(235, 219, 178, 0.9)";
          fadeOnEmpty = false;
          placeholderText = ''<i><span foreground="##ebdbb2e5">Enter Password</span></i>'';
          hideInput = false;
          position = "0, -300";
          halign = "center";
          valign = "center";
        }
      ];
    };
  };
}
