{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.modules.ai.claude;
in {
  options.modules.ai.claude = {
    enable = lib.mkEnableOption "Enable Claude Code module";
  };

  config = lib.mkIf cfg.enable {
    programs.zsh.zsh-abbr.abbreviations = {
      cc = "claude";
    };
    programs.claude-code = {
      enable = true;
      # use the terminal cursor instead of a painted block, so the shape follows vi mode;
      # set on the binary since hm-session-vars is only sourced once per login
      package = pkgs.symlinkJoin {
        inherit (pkgs.llm-agents.claude-code) pname version meta;
        paths = [pkgs.llm-agents.claude-code];
        nativeBuildInputs = [pkgs.makeWrapper];
        postBuild = ''
          wrapProgram $out/bin/claude --set CLAUDE_CODE_NATIVE_CURSOR 1
        '';
      };
      context = ./AGENTS.md;
      # settings = {
      #   model = "claude-fable-5[1m]";
      #   effortLevel = "medium";
      #   modelSettings.claude-fable-5.effortLevel = "medium";
      #   tui = "fullscreen";
      # };
    };
  };
}
