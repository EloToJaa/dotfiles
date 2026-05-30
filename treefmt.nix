{pkgs, ...}: let
  prettierd-treefmt = pkgs.writeShellApplication {
    name = "prettierd-treefmt";
    runtimeInputs = [pkgs.prettierd];
    text = ''
      for file in "$@"; do
        [ -f "$file" ] || continue

        tmpdir="$(mktemp -d)"
        input="$tmpdir/input"
        output="$tmpdir/output"

        cp "$file" "$input"
        prettierd "$file" < "$input" > "$output"

        if cmp -s "$input" "$output"; then
          rm -r "$tmpdir"
          continue
        fi

        mv "$output" "$file"
        rm -r "$tmpdir"
      done
    '';
  };
in {
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

  settings.formatter.prettierd = {
    command = "${prettierd-treefmt}/bin/prettierd-treefmt";
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
