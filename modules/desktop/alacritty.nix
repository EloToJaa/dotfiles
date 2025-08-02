{
  programs.alacritty = {
    enable = true;
    theme = "catppuccin_mocha";
    settings = {
      env = {
        TERM = "xterm-256color";
      };
      font = {
        normal = {
          family = "JetBrainsMono Nerd Font";
          style = "Regular";
        };
        size = 12.4;
      };
      window = {
        padding = {
          x = 4;
          y = 0;
        };
        decorations = "None";
        opacity = 0.9;
        blur = true;
      };
    };
  };
}
