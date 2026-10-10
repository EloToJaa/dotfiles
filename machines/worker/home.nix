{
  imports = [../../homeModules/server.nix];

  modules.ai = {
    t3-code = {
      enable = true;
      service = {
        enable = true;
        tailscaleServe.enable = true;
      };
    };
  };
}
