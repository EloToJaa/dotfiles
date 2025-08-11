{config, ...}: let
  inherit (config.lib.nixvim) mkRaw;
in {
  programs.nixvim = {
    plugins.lspconfig = {
      enable = true;
    };
    lsp = {
      inlayHints.enable = false;
      servers = {
        "*" = {
          settings = {
            capabilities = {
              textDocument = {
                semanticTokens = {
                  multilineTokenSupport = true;
                };
              };
            };
            root_markers = [
              ".git"
            ];
          };
        };
      };
    };
    keymaps = [
      {
        mode = "n";
        key = "<leader>la";
        action = mkRaw "vim.lsp.buf.code_action";
        options.desc = "Code action";
      }
      {
        mode = "n";
        key = "gD";
        action = mkRaw "vim.lsp.buf.declaration";
      }
      {
        mode = "n";
        key = "<leader>rn";
        action = mkRaw "vim.lsp.buf.rename";
        options.desc = "Rename";
      }
      {
        mode = "n";
        key = "<leader>df";
        action = "<cmd>Telescope diagnostics bufnr=0<CR>";
        options.desc = "Show buffer diagnostics";
      }
      {
        mode = "n";
        key = "<leader>ds";
        action = mkRaw "vim.diagnostic.open_float";
        options.desc = "Show line diagnostics";
      }
      {
        mode = "n";
        key = "<leader>rs";
        action = "<cmd>LspRestart<CR>";
        options.desc = "Restart LSP";
      }
    ];
    extraConfigLuaPost = ''
      local signs = { Error = " ", Warn = " ", Hint = "󰠠 ", Info = " " }
      for type, icon in pairs(signs) do
      	local hl = "DiagnosticSign" .. type
      	vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
      end
      vim.diagnostic.config({ virtual_text = true })
    '';
  };
}
