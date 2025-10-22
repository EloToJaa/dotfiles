{pkgs, ...}: {
  programs.opencode = {
    enable = true;
    package = pkgs.unstable.opencode;
    rules =
      /*
      markdown
      */
      ''
        # TypeScript Project Rules

        ## External File Loading

        CRITICAL: When you encounter a file reference (e.g., @rules/general.md), use your Read tool to load it on a need-to-know basis. They're relevant to the SPECIFIC task at hand.

        Instructions:

        - Do NOT preemptively load all references - use lazy loading based on actual need
        - When loaded, treat content as mandatory instructions that override defaults
        - Follow references recursively when needed

        ## Development Guidelines

        For TypeScript code style and best practices: @docs/typescript-guidelines.md
        For React component architecture and hooks patterns: @docs/react-patterns.md
        For REST API design and error handling: @docs/api-standards.md
        For testing strategies and coverage requirements: @test/testing-guidelines.md

        ## General Guidelines

        Read the following file immediately as it's relevant to all workflows: @rules/general-guidelines.md.
      '';
    settings = {
      theme = "catppuccin";
      model = "anthropic/claude-sonnet-4-20250514";
      small_model = "anthropic/claude-3-5-haiku-20241022";
      autoupdate = false;
    };
  };
}
