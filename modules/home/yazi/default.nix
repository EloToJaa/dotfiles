{
  pkgs,
  inputs,
  ...
}: {
  home.packages = with pkgs; [
    exiftool
    jq
    ffmpeg
    ffmpegthumbnailer
    imagemagick
    poppler
    ripgrep # grep replacement
    ripgrep-all # rg for more file types, optional
    fd # find replacement
    file # Show file information
    resvg
    ouch
    glow
    mediainfo
    hexyl
    inputs.yazi.packages."${pkgs.system}".default
  ];

  xdg.configFile = {
    "yazi/yazi.toml".source = ./yazi.toml;
    "yazi/keymap.toml".source = ./keymap.toml;
    "yazi/theme.toml".source = ./theme.toml;
    "yazi/Catppuccin-mocha.tmTheme".source = ./theme.tmTheme;
    "yazi/init.lua".source = ./init.lua;

    # Plugins
    "yazi/plugins/git.yazi".source = pkgs.callPackage ./plugins/git.nix {};
    "yazi/plugins/lazygit.yazi".source = pkgs.callPackage ./plugins/lazygit.nix {};
    "yazi/plugins/smart-filter.yazi".source = pkgs.callPackage ./plugins/smart-filter.nix {};
    "yazi/plugins/smart-enter.yazi".source = pkgs.callPackage ./plugins/smart-enter.nix {};
    "yazi/plugins/chmod.yazi".source = pkgs.callPackage ./plugins/chmod.nix {};
    "yazi/plugins/diff.yazi".source = pkgs.callPackage ./plugins/diff.nix {};
    "yazi/plugins/copy-file-contents.yazi".source = pkgs.callPackage ./plugins/copy-file-contents.nix {};
    "yazi/plugins/system-clipboard.yazi".source = pkgs.callPackage ./plugins/system-clipboard.nix {};
    "yazi/plugins/exifaudio.yazi".source = pkgs.callPackage ./plugins/exifaudio.nix {};
    "yazi/plugins/ouch.yazi".source = pkgs.callPackage ./plugins/ouch.nix {};
    "yazi/plugins/glow.yazi".source = pkgs.callPackage ./plugins/glow.nix {};
    "yazi/plugins/hexyl.yazi".source = pkgs.callPackage ./plugins/hexyl.nix {};
    "yazi/plugins/relative-motions.yazi".source = pkgs.callPackage ./plugins/relative-motions.nix {};
  };

  programs.zsh.initContent =
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
