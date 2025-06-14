{
  programs.nvf.settings.vim.languages = {
    enableFormat = true;
    enableTreesitter = true;
    enableExtraDiagnostics = true;

    astro.enable = true;
    svelte.enable = true;
    ts.enable = true;
    tailwind.enable = true;

    nix = {
      enable = true;
      lsp.server = "nixd";
      format.type = "alejandra";
    };
    python = {
      enable = true;
      lsp.server = "pyright";
      format.type = "ruff";
    };
    go = {
      enable = true;
      lsp.server = "gopls";
      format.type = "gofumpt";
    };
    clang.enable = true;
    zig.enable = true;
    bash.enable = true;
    rust.enable = true;
    nu.enable = true;

    markdown.enable = true;
    yaml.enable = true;
  };
}
