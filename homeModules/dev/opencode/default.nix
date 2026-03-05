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
    inherit (aiTools) workmux;
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
      # btca
      aiTools.workmux
    ];
    programs.zsh.zsh-abbr.abbreviations = {
      oc = "opencode";
    };
    programs.opencode = {
      enable = true;
      package = aiTools.opencode;
      rules = ./AGENTS.md;
      skills = {
        # better-context = "${pkgs.btca}/skills/btca-cli/";
        frontend-design = "${skills.anthropic}/skills/frontend-design/";
      };
      settings = {
        theme = "catppuccin";
        model = "anthropic/claude-opus-4-5";
        small_model = "anthropic/claude-haiku-4-5";
        autoupdate = false;
        plugin = [];
        server.port = 4096;
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
