{pkgs, ...}: let
  name = "flaresolverr";
  port = 8191;
in {
  services.${name} = {
    enable = true;
    package = pkgs.unstable.flaresolverr;
    inherit port;
  };
}
