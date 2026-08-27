{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.modules.desktop.voxtype;
in {
  options.modules.desktop.voxtype = {
    enable = lib.mkEnableOption "Enable Voxtype voice dictation";
  };

  config = lib.mkIf cfg.enable {
    services.voxtype = {
      enable = true;
      package = pkgs.unstable.voxtype-vulkan;
      loadModels = ["base.en"];
      settings = {
        state_file = "auto";

        hotkey = {
          enabled = true;
          key = "SCROLLLOCK";
          mode = "push_to_talk";
        };

        whisper = {
          model = "base.en";
          language = "en";
          translate = false;
        };
      };
    };
  };
}
