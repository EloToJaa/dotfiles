{
  pkgs,
  inputs,
  lib,
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

  imports = [
    inputs.nix-yazi-plugins.legacyPackages.x86_64-linux.homeManagerModules.default
  ];

  programs.yazi = {
    enable = true;
    package = lib.mkForce inputs.yazi.packages."${pkgs.system}".default;
    plugins = {
      # custom = ./custom.nix;
    };
    yaziPlugins = {
      enable = true;
      plugins = {
        relative-motions = {
          enable = true;
          show_numbers = "relative_absolute";
          show_motion = true;
        };
        jump-to-char.enable = true;
        chmod.enable = true;
        copy-file-contents.enable = true;
        # git.enable = true;
        smart-filter.enable = true;
        # glow = {
        #   enable = true;
        # };
        # exifaudio = {
        #   enable = true;
        # };
        # ouch = {
        #   enable = true;
        # };
        # system-clipboard = {
        #   enable = true;
        # };
      };
    };
  };

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
}
