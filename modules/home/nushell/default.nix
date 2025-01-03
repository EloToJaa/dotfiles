{pkgs, ...}: let
  nu_catppuccin = pkgs.callPackage ../../../pkgs/nu_catppuccin.nix {};
in {
  imports = [
    ./nu.nix
  ];
  home.packages = [nu_catppuccin];
}
