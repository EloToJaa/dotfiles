{config, ...}: let
  inherit (config.nixvim.lib) mkRaw;
in {
  programs.nixvim = {
    plugins.lspconfig = {
      enable = true;
    };
    lsp = {
      inlayHints.enable = true;
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
        action = mkRaw "function() vim.lsp.buf.code_action() end";
        options.desc = "Code action";
      }
    ];
  };
}
