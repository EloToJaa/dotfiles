{config, ...}: {
  programs.nixvim.plugins = {
    blink-cmp = {
      enable = true;
      setupLspCapabilities = true;

      settings = {
        sources = {
          default = ["lsp" "path" "snippets" "buffer" "supermaven"];
          providers = {
            lsp = {
              name = "lsp";
              enabled = true;
              module = "blink.cmp.sources.lsp";
              min_keyword_length = 2;
              score_offset = 90;
            };
            supermaven = {
              name = "supermaven";
              module = "blink.compat.source";
              score_offset = 3;
            };
            path = {
              name = "Path";
              module = "blink.cmp.sources.path";
              score_offset = 25;
              fallbacks = ["snippets" "buffer"];
              min_keyword_length = 2;
              opts = {
                trailing_slash = false;
                label_trailing_slash = true;
                get_cwd = config.lib.nixvim.mkRaw ''
                  function(context)
                    if context and context.bufnr then
                      return vim.fn.expand(("#%d:p:h"):format(context.bufnr))
                    end
                    return vim.fn.getcwd()
                  end,
                '';
                show_hidden_files_by_default = true;
              };
            };
            buffer = {
              name = "Buffer";
              enabled = true;
              max_items = 3;
              module = "blink.cmp.sources.buffer";
              min_keyword_length = 4;
              score_offset = 15;
            };
            snippets = {
              name = "snippets";
              enabled = true;
              max_items = 15;
              min_keyword_length = 2;
              module = "blink.cmp.sources.snippets";
              score_offset = 85;
            };
            emoji = {
              name = "Emoji";
              module = "blink-emoji";
            };
            ripgrep = {
              name = "Ripgrep";
              module = "blink-ripgrep";
            };
          };
        };

        cmdline = {
          sources = config.lib.nixvim.mkRaw ''
            function()
              local type = vim.fn.getcmdtype()
              if type == "/" or type == "?" then
                return { "buffer" }
              elseif type == ":" then
                return { "cmdline" }
              end
              return {}
            end,
          '';
        };

        completion = {
          keyword = {range = "full";};
          list = {
            selection = {
              preselect = true; # ✅ Fixed: Boolean instead of string
              auto_insert = true; # ✅ Prevents auto-inserting suggestions
            };
          };
          accept = {auto_brackets = {enabled = true;};};
          menu = {
            border = "rounded";
            auto_show = true;
            draw = {
              columns = [
                {
                  __unkeyed-1 = "label";
                  __unkeyed-2 = "label_description";
                  gap = 1;
                }
                {
                  __unkeyed-1 = "kind_icon";
                  __unkeyed-2 = "kind";
                }
              ];
            };
          };
          documentation = {
            auto_show = true;
            window = {
              border = "single";
            };
          };
          ghost_text = {
            enabled = false;
          };
        };

        snippets = {
          preset = "luasnip";
          expand = config.lib.nixvim.mkRaw ''
            function(snippet)
              local ok, luasnip = pcall(require, "luasnip")
              if ok then
                luasnip.lsp_expand(snippet)
              end
            end,
            active = function(filter)
              local ok, luasnip = pcall(require, "luasnip")
              if ok then
                if filter and filter.direction then
                  return luasnip.jumpable(filter.direction)
                end
                return luasnip.in_snippet()
              end
              return false
            end,
            jump = function(direction)
              local ok, luasnip = pcall(require, "luasnip")
              if ok then
                luasnip.jump(direction)
              end
            end,
          '';
        };

        keymap = {
          preset = "enter";
          # ["<Tab>"] = { "snippet_forward", "fallback" };
          # ["<S-Tab>"] = { "snippet_backward", "fallback" };
          # ["<Up>"] = { "select_prev", "fallback" };
          # ["<Down>"] = { "select_next", "fallback" };
          # ["<C-p>"] = { "select_prev", "fallback" };
          # ["<C-n>"] = { "select_next", "fallback" };
          # ["<S-k>"] = { "scroll_documentation_up", "fallback" };
          # ["<S-j>"] = { "scroll_documentation_down", "fallback" };
          # ["<C-space>"] = { "show", "show_documentation", "hide_documentation" };
          # ["<C-e>"] = { "hide", "fallback" };
        };

        appearance = {
          use_nvim_cmp_as_default = true;
          nerd_font_variant = "Normal";
        };
        signature = {
          enabled = true;
          window = {border = "rounded";};
        };
      };
    };
    blink-compat = {
      enable = true;
      settings = {
        enable_events = true;
        impersonate_nvim_cmp = true;
      };
    };
  };
}
