{
  pkgs,
  config,
  ...
}: let
  inherit (config.lib.nixvim) mkRaw;
in {
  programs.nixvim = {
    extraPlugins = with pkgs.unstable; [vimPlugins.substitute-nvim];
    extraConfigLua = "require('substitute').setup()";
    keymaps = [
      {
        mode = "n";
        key = "s";
        action = mkRaw "function() require('substitute').operator() end";
        options.desc = "Substitute with motion";
      }
      {
        mode = "n";
        key = "ss";
        action = mkRaw "function() require('substitute').line() end";
        options.desc = "Substitute line";
      }
      {
        mode = "n";
        key = "S";
        action = mkRaw "function() require('substitute').eol() end";
        options.desc = "Substitute to end of line";
      }
      {
        mode = "x";
        key = "s";
        action = mkRaw "function() require('substitute').visual() end";
        options.desc = "Substitute in visual mode";
      }
    ];
  };
}
