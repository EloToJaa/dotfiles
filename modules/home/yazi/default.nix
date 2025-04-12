{
  pkgs,
  inputs,
  lib,
  system,
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
    (inputs.nix-yazi-plugins.legacyPackages."${system}".homeManagerModules.default)
  ];

  programs.yazi = {
    enable = true;
    package = lib.mkForce inputs.yazi.packages."${system}".default;
    yaziPlugins = {
      enable = true;
      plugins = {
        jump-to-char = {
          enable = true;
          keys.toggle.on = ["F"];
        };
        relative-motions = {
          enable = true;
          show_numbers = "relative_absolute";
          show_motion = true;
        };
        chmod = {
          enable = true;
        };
        git = {
          enable = true;
        };
        # glow = {
        #   enable = true;
        # };
        # exifaudio = {
        #   enable = true;
        # };
        max-preview = {
          enable = true;
        };
        hide-preview = {
          enable = true;
        };
        # ouch = {
        #   enable = true;
        # };
        smart-filter = {
          enable = true;
        };
        # system-clipboard = {
        #   enable = true;
        # };
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
