{config, ...}: let
  inherit (config.lib.nixvim) mkRaw;
in {
  programs.nixvim = {
    plugins.conform-nvim = {
      enable = true;
      # settings.format_on_save = {
      #   lsp_fallback = true;
      #   async = false;
      #   timeout = 1000;
      # };
      settings.format_on_save =
        mkRaw
        /*
        lua
        */
        ''
          function(bufnr)
            -- Disable with a global or buffer-local variable
            if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
              return
            end
            return { timeout_ms = 500, lsp_format = "fallback" }
          end
        '';
    };
    extraConfigLuaPre =
      /*
      lua
      */
      ''
        vim.api.nvim_create_user_command("FormatDisable", function(args)
          if args.bang then
            -- FormatDisable! will disable formatting just for this buffer
            vim.b.disable_autoformat = true
          else
            vim.g.disable_autoformat = true
          end
        end, {
          desc = "Disable autoformat-on-save",
          bang = true,
        })
        vim.api.nvim_create_user_command("FormatEnable", function()
          vim.b.disable_autoformat = false
          vim.g.disable_autoformat = false
        end, {
          desc = "Re-enable autoformat-on-save",
        })
      '';
    keymaps = [
      {
        mode = "n";
        key = "<leader>ce";
        action = ":FormatEnable";
        options.desc = "Enable code formating on save";
      }
      {
        mode = "n";
        key = "<leader>cd";
        action = ":FormatDisable";
        options.desc = "Disable code formating on save";
      }
    ];
  };
}
