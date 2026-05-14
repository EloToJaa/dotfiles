{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.modules.dev.ai.ollama;
in {
  options.modules.dev.ai.ollama = {
    enable = lib.mkEnableOption "Enable ollama module";
  };

  config = lib.mkIf cfg.enable {
    services.ollama = {
      enable = true;
      package = pkgs.unstable.ollama-rocm;
      acceleration = "rocm";
      host = "127.0.0.1";
      port = 11434;
    };
  };
}
