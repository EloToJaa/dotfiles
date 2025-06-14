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

      lsp = {
        enable = true;
        formatOnSave = true;
        trouble = {
          enable = true;

          setupOpts.focus = true;
        };
        lspSignature.enable = true;
        lspconfig.enable = true;
        # null-ls.enable = false;
        inlayHints.enable = true;
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

      theme = {
        enable = true;
        name = "catppuccin";
        style = variables.catppuccin.flavor;
        transparent = true;
      };

      autopairs.nvim-autopairs.enable = true;
      autocomplete.nvim-cmp.enable = true;
      snippets.luasnip.enable = true;
      tabline.nvimBufferline = {
        enable = true;
        setupOpts.options = {
          mode = "tabs";
          numbers = "ordinal";
        };
      };
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

      comments.comment-nvim.enable = true;

      extraPlugins = with pkgs.vimPlugins; {
        supermaven = {
          package = supermaven-nvim;
          setup = ''
            require("supermaven-nvim").setup({
            	keymaps = {
            		accept_suggestion = "<Tab>",
            		clear_suggestion = "<C-]>",
            		accept_word = "<C-j>",
            	},
            	-- ignore_filetypes = { cpp = true },
            	color = {
            		suggestion_color = "#ffffff",
            		cterm = 244,
            	},
            	log_level = "info", -- set to "off" to disable logging completely
            	disable_inline_completion = false, -- disables inline completion for use with cmp
            	disable_keymaps = false, -- disables built in keymaps for more manual control
            	condition = function() return false end, -- condition to check for stopping supermaven, `true` means to stop supermaven when the condition is true.
            })
          '';
        };
      };
    };
  };
}
