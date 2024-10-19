{ inputs, pkgs, host, ... }:
{
  programs.wezterm = {
    enable = true;
    package = inputs.wezterm.packages.${pkgs.system}.default;
    extraConfig = ''
      local Config = require('config')

      require('events.right-status').setup()
      require('events.left-status').setup()
      require('events.tab-title').setup()
      require('events.new-tab-button').setup()

      return Config:init()
        :append(require('config.appearance'))
        :append(require('config.bindings'))
        :append(require('config.domains'))
        :append(require('config.fonts'))
        :append(require('config.general'))
        :append(require('config.launch')).options
    '';
  };

  xdg.configFile."wezterm/colors/custom.lua".source = ./colors/custom.lua;

  xdg.configFile."wezterm/config/appearance.lua".source = ./config/appearance.lua;
  xdg.configFile."wezterm/config/bindings.lua".source = ./config/bindings.lua;
  xdg.configFile."wezterm/config/domains.lua".source = ./config/domains.lua;
  xdg.configFile."wezterm/config/fonts.lua".source = ./config/fonts.lua;
  xdg.configFile."wezterm/config/general.lua".source = ./config/general.lua;
  xdg.configFile."wezterm/config/init.lua".source = ./config/init.lua;
  xdg.configFile."wezterm/config/launch.lua".source = ./config/launch.lua;

  xdg.configFile."wezterm/events/left-status.lua".source = ./events/left-status.lua;
  xdg.configFile."wezterm/events/new-tab-button.lua".source = ./events/new-tab-button.lua;
  xdg.configFile."wezterm/events/right-status.lua".source = ./events/right-status.lua;
  xdg.configFile."wezterm/events/tab-title.lua".source = ./events/tab-title.lua;

  xdg.configFile."wezterm/utils/cells.lua".source = ./utils/cells.lua;
  xdg.configFile."wezterm/utils/gpu_adapter.lua".source = ./utils/gpu_adapter.lua;
  xdg.configFile."wezterm/utils/math.lua".source = ./utils/math.lua;
  xdg.configFile."wezterm/utils/platform.lua".source = ./utils/platform.lua;
}
