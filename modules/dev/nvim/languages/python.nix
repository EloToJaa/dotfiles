{
  pkgs,
  config,
  ...
}: {
  home.packages = with pkgs; [
    uv
    ruff

    (python312.withPackages (pypkgs:
      with pypkgs; [
        click
        requests
        flask
        pip
        pipx
        pwntools
        ropper
        # angr
        pycryptodome
      ]))
  ];

  programs.nixvim = {
    lsp.servers.pyright = {
      enable = true;

      settings = {
        pyright.disableOrganizeImports = true;
        python.analysis.ignore = {
          __unkeyed-1 = "*";
        };
      };
    };
    plugins = {
      lint.lintersByFt = {
        python = ["ruff"];
      };
      conform-nvim.settings = {
        formatters_by_ft = {
          python = ["ruff" "ruff_organize_imports"];
        };
        formatters = {
          ruff_organize_imports = {
            command = "ruff";
            args = [
              "check"
              "--force-exclude"
              "--select=I001"
              "--fix"
              "--exit-zero"
              "--stdin-filename"
              "$FILENAME"
              "-"
            ];
            stdin = true;
            cwd = config.lib.nixvim.mkRaw ''
              require("conform.util").root_file({
                "pyproject.toml",
                "ruff.toml",
                ".ruff.toml",
              })
            '';
          };
        };
      };
      treesitter.settings.ensure_installed = [
        "python"
      ];
    };
  };
}
