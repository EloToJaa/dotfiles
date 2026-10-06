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
    codex.enable = true;
    claude.enable = true;
    pi.enable = true;
  };
}
