{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.modules.dev.opencode;
in {
  options.modules.dev.opencode = {
    enable = lib.mkEnableOption "Enable opencode module";
  };
  config = lib.mkIf cfg.enable {
    home.sessionVariables = {
      OPENCODE_EXPERIMENTAL_LSP_TOOL = "true";
    };
    # home.packages = [pkgs.btca];
    programs.zsh.zsh-abbr.abbreviations = {
      oc = "opencode";
    };
    programs.opencode = {
      enable = true;
      package = pkgs.unstable.opencode;
      rules =
        /*
        markdown
        */
        ''
          # Project Rules

          ## External File Loading

          CRITICAL: When you encounter a file reference (e.g., @rules/general.md), use your Read tool to load it on a need-to-know basis. They're relevant to the SPECIFIC task at hand.

          Instructions:

          - Do NOT preemptively load all references - use lazy loading based on actual need
          - When loaded, treat content as mandatory instructions that override defaults
          - Follow references recursively when needed

          ## Development Guidelines

          Whenever possible avoid using if else statements, instead use if guards. This will make your code more readable and maintainable.
          For TypeScript code style and best practices: @docs/typescript-guidelines.md
          For React component architecture and hooks patterns: @docs/react-patterns.md
          For REST API design and error handling: @docs/api-standards.md
          For testing strategies and coverage requirements: @test/testing-guidelines.md

          ## Documentation

          Whenever user says for `use btca` or asks for documentation of a project use btca. You can also use btca whenever you need additional information about the latest tech.

          Commands you should use:

          - `btca ask <question>` - ask a question about the project
          - `btca config resources list` - list all configured resources
          - `btca config resources add --name <name> --url <git_url> --branch <branch> --notes <ai_notes>` - use only if the required resource is not available in the list

          ## General Guidelines

          Read the following file immediately as it's relevant to all workflows: @rules/general-guidelines.md.
        '';
      settings = {
        theme = "catppuccin";
        model = "anthropic/claude-opus-4-5";
        small_model = "anthropic/claude-haiku-4-5";
        autoupdate = false;
        plugin = ["opencode-pty"];
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
