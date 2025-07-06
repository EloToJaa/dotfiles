{pkgs, ...}: {
  home.packages = with pkgs; [
    rustc
    rustfmt
    cargo
  ];

  programs.nixvim = {
    lsp.servers.rust_analyzer = {
      enable = true;

      settings = {
        imports = {
          granularity.group = "module";
          prefix = "crate";
        };
        cargo = {
          allFeatures = true;
          buildScripts.enable = true;
        };
        checkOnSave.command = "clippy";
        procMacro.enable = true;
      };
    };
    plugins = {
      conform-nvim.settings.formatters_by_ft = {
        rust = ["rustfmt"];
      };
      treesitter.settings.ensure_installed = [
        "rust"
      ];
    };
  };
}
