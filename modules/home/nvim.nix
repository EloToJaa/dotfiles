{ inputs, ... }:
{
  imports = [ inputs.nixvim.homeManagerModules.nixvim ];

  programs.nixvim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
    # colorscheme = "";

    plugins.lsp = {
      enable = true;
      servers = {
        ts_ls.enable = true;
        lua_ls.enable = true;
        rust_analyzer = {
          enable = true;
          installCargo = true;
          installRustc = true;
        };
      };
    };

    plugins.cmp = {
      enable = true;
      autoEnableSources = true;
      settings.sources = [
        { name = "nvim_lsp"; }
        { name = "path"; }
        { name = "buffer"; }
      ];

      # mapping = {
      #   "<CR>" = "cmp.mapping.confirm({ select = true })";
      #   "<Tab>" = {
      #     action = ''
      #     function(fallback)
      #       if cmp.visible() then
      #         cmp.select_next_item()
      #       elseif luasnip.expandable() then
      #         luasnip.expand()
      #       elseif luasnip.expand_or_jumpable() then
      #         luasnip.expand_or_jump()
      #       elseif check_backspace() then
      #         fallback()
      #       else
      #         fallback()
      #       end
      #     end
      #     '';
      #     modes = [ "i" "s" ];
      #   };
      # };
    };
  };
}
