{ inputs, pkgs, host, config, ... }:
{
  home.packages = [ inputs.wezterm.packages.${pkgs.system}.default ];
  # programs.wezterm = {
  #   enable = true;
  #   package = inputs.wezterm.packages.${pkgs.system}.default;
  #   extraConfig = ''
  #     local Config = require('config')

  #     require('events.right-status').setup()
  #     require('events.left-status').setup()
  #     require('events.tab-title').setup()
  #     require('events.new-tab-button').setup()

  #     return Config:init()
  #       :append(require('config.appearance'))
  #       :append(require('config.bindings'))
  #       :append(require('config.domains'))
  #       :append(require('config.fonts'))
  #       :append(require('config.general'))
  #       :append(require('config.launch')).options
  #   '';
  # };

  xdg.configFile."wezterm".source = ./src;
}
