{
  pkgs,
  inputs,
  variables,
  ...
}: {
  home.packages = with pkgs; [
    exiftool
    jq
    ffmpeg
    ffmpegthumbnailer
    imagemagick
    poppler
    resvg
    ouch
    glow
    mediainfo
    # yazi
  ];

  programs.zsh.initExtra =
    /*
    sh
    */
    ''
      function y() {
      	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
      	yazi "$@" --cwd-file="$tmp"
      	if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
      		builtin cd -- "$cwd"
      	fi
      	rm -f -- "$tmp"
      }
    '';

  programs.nushell.extraEnv =
    /*
    nu
    */
    ''
      def --env y [...args] {
       let tmp = (mktemp -t "yazi-cwd.XXXXXX")
       yazi ...$args --cwd-file $tmp
       let cwd = (open $tmp)
       if $cwd != "" and $cwd != $env.PWD {
        cd $cwd
       }
       rm -fp $tmp
      }
    '';

  imports = [
    (inputs.nix-yazi-plugins.legacyPackages.x86_64-linux.homeManagerModules.default)
  ];

  # catppuccin.yazi = {
  #   enable = true;
  #   flavor = "${variables.catppuccin.flavor}";
  #   accent = "${variables.catppuccin.accent}";
  # };

  programs.yazi = {
    enable = true;
  };

  programs.yazi.yaziPlugins = {
    enable = true;
    plugins = {
      relative-motions = {
        enable = true;
      };
    };
  };

  # xdg.configFile = {
  #   "yazi/yazi.toml".source = ./yazi.toml;
  #   "yazi/keymap.toml".source = ./keymap.toml;
  #   "yazi/theme.toml".source = ./theme.toml;
  #   "yazi/Catppuccin-mocha.tmTheme".source = ./theme.tmTheme;
  #   "yazi/init.lua".source = ./init.lua;
  # };
}
