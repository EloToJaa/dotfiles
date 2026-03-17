{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  cfg = config.modules.dev.opencode;
  aiTools = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system};
  skills = {
    # inherit (pkgs) btca;
    anthropic = pkgs.callPackage ./pkgs/anthropics-skills.nix {};
  };
in {
  options.modules.dev.opencode = {
    enable = lib.mkEnableOption "Enable opencode module";
  };
  imports = [
    ./workmux.nix
  ];
  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      btca
    ];
    programs.zsh.zsh-abbr.abbreviations = {
      oc = "opencode";
    };
    programs.opencode = {
      enable = true;
      package = aiTools.opencode;
      rules = ./AGENTS.md;
      skills = {
        better-context = "${pkgs.btca}/skills/btca-cli/";
        frontend-design = "${skills.anthropic}/skills/frontend-design/";
      };
      settings = {
        theme = "catppuccin";
        model = "opencode-go/kimi-k2.5";
        autoupdate = false;
        autoshare = false;
        plugin = [];
        # server.port = 4096;
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
