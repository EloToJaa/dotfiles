{
  pkgs,
  lib,
  config,
  settings,
  host,
  ...
}: let
  inherit (settings) dotfilesDirectory;
  cfg = config.modules.dev.zed;

  # mirrors the language setup in ./nvim/languages
  external = command: arguments: {
    formatter.external = {
      command = lib.getExe command;
      inherit arguments;
    };
  };
  clangFormat.formatter.external = {
    command = lib.getExe' pkgs.unstable.clang-tools "clang-format";
    arguments = ["--assume-filename={buffer_path}"];
  };
  # oxfmt replaces prettier
  oxfmtFormatter =
    external pkgs.unstable.oxfmt ["--stdin-filepath" "{buffer_path}"]
    // {prettier.allowed = false;};
  # oxlint replaces eslint
  lintServers = ["oxlint" "!eslint"];
  tsServers =
    [
      "typescript-ls" # tsgo extension
      "!vtsls"
      "!typescript-language-server"
    ]
    ++ lintServers
    ++ ["..."];
  flake = ''(builtins.getFlake "${dotfilesDirectory}")'';
in {
  options.modules.dev.zed = {
    enable = lib.mkEnableOption "Enable Zed editor";
  };

  config = lib.mkIf cfg.enable {
    programs.zed-editor = {
      enable = true;
      package = pkgs.unstable.zed-editor;
      installRemoteServer = true;

      # zed can still write its own changes; nix-declared values are merged on activation
      mutableUserSettings = true;
      mutableUserKeymaps = true;

      extensions = [
        "catppuccin"
        "astro"
        "basher"
        "csharp"
        "html"
        "just"
        "lua"
        "markdown-oxide"
        "nix"
        "oxc"
        "svelte"
        "terraform"
        "toml"
        "tsgo"
        "xml"
        "zig"
      ];

      extraPackages = with pkgs.unstable; [
        # bash
        bash-language-server
        shfmt
        # c/c++
        clang-tools
        # c#
        roslyn-ls
        csharpier
        # go
        gopls
        gofumpt
        # javascript/typescript
        astro-language-server
        svelte-language-server
        tailwindcss-language-server
        vscode-langservers-extracted
        oxlint
        oxfmt
        # just
        just-lsp
        # lua
        lua-language-server
        stylua
        # markdown
        markdown-oxide
        # nix
        nixd
        alejandra
        # python
        pyright
        ruff
        # rust
        cargo
        rustc
        rust-analyzer
        rustfmt
        clippy
        # terraform
        terraform
        terraform-ls
        # toml
        taplo
        # xml
        lemminx
        # yaml
        yaml-language-server
        # zig
        zls
      ];

      userSettings = {
        # theme is set by catppuccin home-manager module
        buffer_font_family = "JetBrains Mono";
        ui_font_family = "JetBrains Mono";
        vim_mode = true;
        format_on_save = "on";

        project_panel.dock = "left";
        outline_panel.dock = "left";
        git_panel.dock = "left";
        agent = {
          dock = "right";
          button = false;
        };

        languages =
          lib.genAttrs [
            "JSON"
            "JSONC"
            "JSON5"
            "CSS"
            "SCSS"
            "LESS"
            "HTML"
            "GraphQL"
            "Handlebars"
            "Markdown"
            "MDX"
            "YAML"
            "TOML"
          ] (_: oxfmtFormatter)
          // lib.genAttrs ["Svelte" "Astro" "Vue.js"] (_: oxfmtFormatter // {language_servers = lintServers ++ ["..."];})
          // lib.genAttrs ["JavaScript" "JSX" "TypeScript" "TSX"] (_: oxfmtFormatter // {language_servers = tsServers;})
          // {
            "Shell Script" = external pkgs.unstable.shfmt ["--filename" "{buffer_path}"];
            C = clangFormat;
            "C++" = clangFormat;
            CSharp =
              external pkgs.unstable.csharpier ["format" "--write-stdout"]
              // {
                language_servers = ["roslyn" "!omnisharp" "!csharp-ls" "..."];
                tab_size = 4;
                hard_tabs = false;
              };
            Go = external pkgs.unstable.gofumpt [];
            Lua = external pkgs.unstable.stylua ["--stdin-filepath" "{buffer_path}" "-"];
            Nix =
              external pkgs.unstable.alejandra ["--quiet" "-"]
              // {language_servers = ["nixd" "!nil" "..."];};
            Python = {
              language_servers = ["pyright" "ruff" "!basedpyright" "!ty" "!pylsp" "..."];
              code_actions_on_format."source.organizeImports.ruff" = true;
              formatter.language_server.name = "ruff";
            };
            Rust = {
              formatter.language_server.name = "rust-analyzer"; # runs rustfmt
            };
          };

        lsp = {
          nixd.settings = {
            formatting.command = ["alejandra"];
            nixpkgs.expr = "import ${flake}.inputs.nixpkgs { }";
            options = {
              nixos.expr = "${flake}.nixosConfigurations.${host}.options";
              home-manager.expr = "${flake}.nixosConfigurations.${host}.options.home-manager.users.type.getSubOptions []";
            };
          };
          gopls.initialization_options = {
            analyses.unusedparams = true;
            staticcheck = true;
            gofumpt = true;
          };
          pyright.settings = {
            pyright.disableOrganizeImports = true;
            python.analysis.ignore = ["*"]; # ruff handles diagnostics
          };
          rust-analyzer.initialization_options = {
            imports = {
              granularity.group = "module";
              prefix = "crate";
            };
            cargo = {
              allFeatures = true;
              buildScripts.enable = true;
            };
            check.command = "clippy";
            procMacro.enable = true;
          };
          roslyn.binary = {
            path = lib.getExe pkgs.unstable.roslyn-ls;
            arguments = ["--stdio" "--autoLoadProjects"];
          };
          oxlint.binary = {
            path = lib.getExe pkgs.unstable.oxlint;
            arguments = ["--lsp"];
          };
          oxfmt.binary = {
            path = lib.getExe pkgs.unstable.oxfmt;
            arguments = ["--lsp"];
          };
        };
      };

      # mirrors the nvim lsp keymaps
      userKeymaps = [
        {
          context = "vim_mode == normal && !menu";
          bindings = {
            "space l a" = "editor::ToggleCodeActions";
            "space r n" = "editor::Rename";
            "space d f" = "diagnostics::Deploy";
            "space d s" = "editor::Hover";
            "space r s" = "editor::RestartLanguageServer";
            "g D" = "editor::GoToDeclaration";
          };
        }
      ];
    };
  };
}
