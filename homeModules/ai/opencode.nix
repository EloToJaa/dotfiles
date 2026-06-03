{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.modules.ai.opencode;
in {
  options.modules.ai.opencode = {
    enable = lib.mkEnableOption "Enable opencode module";
  };

  config = lib.mkIf cfg.enable {
    programs.zsh.zsh-abbr.abbreviations = {
      oc = "opencode";
    };
    catppuccin.opencode.enable = false;
    programs.opencode = {
      enable = true;
      package = pkgs.llm-agents.opencode;
      context = ./AGENTS.md;
      tui = {
        theme = "catppuccin";
        keybinds = {
          "input_submit" = "return";
          "input_newline" = "shift+return";
        };
      };
      settings = {
        model = "openai/gpt-5.5";
        autoupdate = false;
        autoshare = false;
        plugin = [];
        # server.port = 4096;
        permission.external_directory = {
          "/nix/store/**" = "allow";
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
