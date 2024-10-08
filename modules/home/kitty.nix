
{ pkgs, host, variables, ... }:
{
  programs.kitty = {
    enable = true;

    catppuccin = {
      enable = true;
      flavor = "${variables.catppuccin.flavor}";
    };
    
    font = {
      name = "CaskaydiaCove Nerd Font";
      size = if (host == "laptop") then 16 else 16;
    };

    settings = {
      confirm_os_window_close = 0;
      background_opacity = "0.75";
      scrollback_lines = 10000;
      enable_audio_bell = false;
      mouse_hide_wait = 60;
      
      ## Tabs
      tab_title_template = "{index}";
      active_tab_font_style = "normal";
      inactive_tab_font_style = "normal";
      tab_bar_style = "powerline";
      tab_powerline_style = "angled";
      # active_tab_foreground = "#11111B";
      # active_tab_background = "#CBA6F7";
      # inactive_tab_foreground = "#CDD6F4";
      # inactive_tab_background = "#181825";
    };

    keybindings = {  
      ## Tabs
      "alt+1" = "goto_tab 1";
      "alt+2" = "goto_tab 2";
      "alt+3" = "goto_tab 3";
      "alt+4" = "goto_tab 4";

      ## Unbind
      "ctrl+shift+left" = "no_op";
      "ctrl+shift+right" = "no_op";
    };
  };
}
