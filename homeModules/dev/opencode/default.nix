{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.modules.dev.opencode;
  skills = pkgs.callPackage ./pkgs/anthropics-skills.nix {};
in {
  options.modules.dev.opencode = {
    enable = lib.mkEnableOption "Enable opencode module";
  };
  config = lib.mkIf cfg.enable {
    home.sessionVariables = {
      OPENCODE_EXPERIMENTAL_LSP_TOOL = "true";
    };
    home.packages = with pkgs; [btca];
    programs.zsh.zsh-abbr.abbreviations = {
      oc = "opencode";
    };
    programs.opencode = {
      enable = true;
      package = pkgs.unstable.opencode;
      rules = ./AGENTS.md;
      skills = {
        better-context = "${pkgs.btca}/skills/btca-cli/";
        frontend-design = "${skills}/skills/frontend-design/";
      };
      settings = {
        theme = "catppuccin";
        model = "anthropic/claude-opus-4-5";
        small_model = "anthropic/claude-haiku-4-5";
        autoupdate = false;
        plugin = [];
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
