{
  imports = [../../homeModules/server.nix];

  modules = {
    ai = {
      grok.enable = true;
      cursor.enable = true;
      t3-code = {
        enable = true;
        service.enable = true;
      };
    };
  };
}
