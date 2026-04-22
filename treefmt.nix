{pkgs, ...}: {
  projectRootFile = "flake.nix";

  programs = {
    alejandra.enable = true;
    stylua.enable = true;
    ruff-format.enable = true;
    shfmt = {
      enable = true;
      indent_size = 2;
    };
    yamlfmt.enable = true;
    taplo.enable = true;
    mdformat.enable = true;
  };

  settings.global.excludes = [
    # Lock file
    "flake.lock"
    # Encrypted secrets
    "secrets/**"
    "sops/**"
    # Markdown with YAML frontmatter (mdformat doesn't support frontmatter)
    "homeModules/dev/ai/commands/*.md"
    # Generated or external files
    ".luacheckrc"
  ];
}
