{config, ...}: let
  inherit (config.lib.nixvim) mkRaw;
in {
  programs.nixvim = {
    plugins.lspconfig = {
      enable = true;
    };
    lsp = {
      inlayHints.enable = false;
      # servers = {
      #   "*" = {
      #     settings = {
      #       capabilities = {
      #         textDocument = {
      #           semanticTokens = {
      #             multilineTokenSupport = true;
      #           };
      #         };
      #       };
      #       root_markers = [
      #         ".git"
      #       ];
      #     };
      #   };
      # };
    };
    keymaps = [
      {
        mode = "n";
        key = "<leader>la";
        action = mkRaw "vim.lsp.buf.code_action";
        options.desc = "Code action";
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
