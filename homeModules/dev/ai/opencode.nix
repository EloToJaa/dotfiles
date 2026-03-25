{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  cfg = config.modules.dev.ai.opencode;
  aiTools = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system};
in {
  options.modules.dev.ai.opencode = {
    enable = lib.mkEnableOption "Enable opencode module";
  };
  config = lib.mkIf cfg.enable {
    programs.zsh.zsh-abbr.abbreviations = {
      oc = "opencode";
    };
    programs.opencode = {
      enable = true;
      package = aiTools.opencode;
      rules = ./AGENTS.md;
      skills = {
      };
      settings = {
        theme = "catppuccin";
        model = "opencode-go/kimi-k2.5";
        autoupdate = false;
        autoshare = false;
        plugin = [];
        # server.port = 4096;
        permissions.external_directory = {
          "/nix/store/**" = "allow";
        };
        keybinds = {
          "input_submit" = "return";
          "input_newline" = "shift+return";
        };
        tools = {
          write = true;
          edit = true;
          read = true;
          bash = true;
          webfetch = true;
          lsp = true;
        };
        formatter = {
          alejandra = {
            command = ["alejandra" "$FILE"];
            extensions = [".nix"];
          };
          nixfmt.disabled = true;
        };
      };
    };
  };
}
