{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.modules.home.oh-my-posh;
in {
  options.modules.home.oh-my-posh = {
    enable = lib.mkEnableOption "Enable oh-my-posh";
  };
  config = lib.mkIf cfg.enable {
    # https://github.com/NovaViper/NixConfig/blob/51a5e1c261edb1deffaba6173a44de8d1002bee7/features/home/cli/prompt/oh-my-posh/posh.nix
    programs.oh-my-posh = {
      enable = true;
      enableZshIntegration = true;
      enableBashIntegration = true;
      package = pkgs.unstable.oh-my-posh;
      settings = {
        "$schema" = "https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/schema.json";
        version = 2;
        final_space = true;
        disable_notice = true;
        transient_prompt = {
          background = "transparent";
          foreground_templates = [
            "{{if gt .Code 0}}1{{end}}"
            "{{if eq .Code 0}}10{{end}}"
          ];
          template = "{{.Var.PromptChar}} ";
        };
      };
    };
  };
  imports = [
    ./blocks.nix
    ./snippet.nix
  ];
}
