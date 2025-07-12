{
  pkgs,
  inputs,
  ...
}: {
  home.packages = with pkgs; [
    ## CLI utility
    comma
    gtrash # rm replacement, put deleted files in system trash
    killall
    man-pages # extra man pages
    openssl
    usbutils
    unzip
    wget
    systemctl-tui

    inputs.wezterm.packages.${pkgs.system}.default

    # neovim
  ];
}
