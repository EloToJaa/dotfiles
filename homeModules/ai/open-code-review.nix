{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.modules.ai.open-code-review;
in {
  options.modules.ai.open-code-review.enable = lib.mkEnableOption "Enable Open Code Review module";

  config = lib.mkIf cfg.enable {
    home.packages = [pkgs.llm-agents.open-code-review];
    home.file.".opencodereview/config.json".text = builtins.toJSON {
      language = "English";
      provider = "openai-responses";
      providers."openai-responses".model = "gpt-6-luna";
    };
  };
}
