{variables, ...}: {
  programs.nvf = {
    enable = true;
    defaultEditor = true;
    enableManpages = true;

    settings.vim = {
      viAlias = false;
      vimAlias = false;

      lsp = {
        enable = true;
        formatOnSave = true;
        trouble.enable = true;
        lspSignature.enable = true;
        lspconfig.enable = true;
      };

      languages = {
        enableFormat = true;
        enableTreesitter = true;
        enableExtraDiagnostics = true;

        astro.enable = true;
        svelte.enable = true;
        ts.enable = true;
        tailwind.enable = true;

        nix.enable = true;
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

      statusline = {
        lualine = {
          enable = true;
          theme = "catppuccin";
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

      telescope.enable = true;

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
        yazi-nvim.enable = true;
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
        {
          mode = "n";
          key = "<leader>fv";
          desc = "Open yazi at the current file";
        }
      ];
    };
  };
}
