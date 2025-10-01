{pkgs, ...}: let
  port = 8191;
in {
  services.flaresolverr = {
    enable = true;
    package = pkgs.unstable.flaresolverr;
    inherit port;
  };
}
