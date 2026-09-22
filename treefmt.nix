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
  };

  settings.formatter.oxfmt = {
    command = "${pkgs.oxfmt}/bin/oxfmt";
    includes = [
      "*.md"
      "*.mdx"
    ];
  };

  settings.global.excludes = [
    # Lock file
    "flake.lock"
    # Encrypted secrets
    "secrets/**"
    "sops/**"
    # Generated or external files
    ".luacheckrc"
  ];
}
