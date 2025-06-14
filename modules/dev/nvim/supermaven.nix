{
  config,
  pkgs,
  ...
}: let
  cfg = config.vim.supermaven;
in {
  vim.lazy.plugins.supermaven = {
    # instead of vim.startPlugins, use this:
    package = pkgs.vimPlugins.supermaven-nvim;

    # if your plugin uses the `require('your-plugin').setup{...}` pattern
    setupModule = "supermaven-nvim";
    inherit (cfg) setupOpts;

    # events that trigger this plugin to be loaded
    # event = ["DirChanged"];
    # cmd = ["YourPluginCommand"];
  };
}
