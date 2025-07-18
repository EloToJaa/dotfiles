let
  name = "flaresolverr";
  port = 8191;
in {
  services.${name} = {
    enable = true;
    inherit port;
  };
}
