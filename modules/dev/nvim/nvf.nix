{
  variables,
  pkgs,
  ...
}: {
  programs.nvf = {
    enable = true;
    defaultEditor = true;
    enableManpages = true;

    settings.vim = {
      viAlias = false;
      vimAlias = false;

      options = {
        nu = true;
        relativenumber = true;

        tabstop = 2;
        softtabstop = 2;
        shiftwidth = 2;
        expandtab = true;

        smartindent = true;

        swapfile = false;
        backup = false;
        # undodir = { os.getenv("HOME") .. "/.vim/undodir" }
        # undofile = true;

        hlsearch = false;
        incsearch = true;

        termguicolors = true;

        scrolloff = 8;
        signcolumn = "yes";
        # isfname:append("@-@")

        updatetime = 50;

        colorcolumn = "80";

        wrap = true;
        linebreak = true;
        breakindent = true;
      };

      lsp = {
        enable = true;
        formatOnSave = true;
        trouble = {
          enable = true;

          setupOpts = {
            focus = true;
          };
        };
        lspSignature.enable = true;
        lspconfig.enable = true;
        null-ls.enable = false;
        inlayHints.enable = true;
      };

      languages = {
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

      visuals = {
        nvim-scrollbar.enable = true;
        nvim-web-devicons.enable = true;
        nvim-cursorline.enable = true;
        fidget-nvim.enable = true;
        highlight-undo.enable = true;
        indent-blankline.enable = true;
        cinnamon-nvim.enable = true;
      };

      statusline.lualine = {
        enable = true;
        theme = "catppuccin";

        sectionSeparator = {
          left = "";
          right = "";
        };
        componentSeparator = {
          left = "";
          right = "";
        };

        activeSection = {
          a = [
            ''
              {
              	"mode",
              	separator = { left = "", right = "" },
              }
            ''
          ];
          b = [];
          c = [];
          x = [
            ''{ "encoding" }''
            ''{ "fileformat" }''
            ''{ "filetype" }''
          ];
          y = [];
          z = [
            ''
              {
              	"location",
              	separator = { left = "", right = "" },
              }
            ''
          ];
        };
      };

      theme = {
        enable = true;
        name = "catppuccin";
        style = variables.catppuccin.flavor;
        transparent = false;
      };

      autopairs.nvim-autopairs.enable = true;
      autocomplete.nvim-cmp.enable = true;
      snippets.luasnip.enable = true;
      filetree.neo-tree.enable = true;
      tabline.nvimBufferline.enable = true;
      treesitter.context.enable = true;

      binds = {
        whichKey.enable = true;
        cheatsheet.enable = true;
      };

      telescope = {
        enable = true;

        mappings = {
          findFiles = "<C-p>";
          liveGrep = "<leader>fs";
        };

        extensions = [
          {
            name = "fzf";
            packages = [pkgs.vimPlugins.telescope-fzf-native-nvim];
            setup = {
              fzf = {
                fuzzy = true;
                override_generic_sorter = true;
                override_file_sorter = true;
                case_mode = "smart_case";
              };
            };
          }
        ];
      };

      git = {
        enable = true;
        gitsigns = {
          enable = true;
          codeActions.enable = true;
        };
      };

      notify = {
        nvim-notify.enable = true;
      };

      projects = {
        project-nvim.enable = true;
      };

      utility = {
        surround.enable = true;
        diffview-nvim.enable = true;
        yazi-nvim = {
          enable = true;
          mappings = {
            openYazi = "<leader>fv";
          };
        };
        motion = {
          hop.enable = true;
          leap.enable = true;
        };
      };

      notes = {
        todo-comments.enable = true;
      };

      terminal = {
        toggleterm = {
          enable = true;
          lazygit.enable = true;
        };
      };

      ui = {
        borders.enable = true;
        noice.enable = true;
        colorizer.enable = true;
        illuminate.enable = true;
        breadcrumbs = {
          enable = true;
          navbuddy.enable = true;
        };
      };

      comments = {
        comment-nvim.enable = true;
      };

      keymaps = [
        {
          mode = "n";
          key = "<leader>rp";
          action = ":lua require('precognition').peek()<CR>";
          desc = "Peek recognition";
        }
      ];
    };
  };
}
