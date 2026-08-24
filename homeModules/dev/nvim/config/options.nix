{
  config,
  lib,
  ...
}: let
  cfg = config.modules.dev.nvim;
in {
  config = lib.mkIf cfg.enable {
    programs.nixvim = {
      opts = {
        number = true;
        relativenumber = true;

        tabstop = 2;
        softtabstop = 2;
        shiftwidth = 2;
        expandtab = true;

        smartindent = true;

        swapfile = false;
        backup = false;
        # undodir = { os.getenv("HOME") .. "/.vim/undodir" }
        undofile = true;
        autoread = true;

        hlsearch = false;
        incsearch = true;

        termguicolors = true;

        scrolloff = 8;
        signcolumn = "yes";

        updatetime = 50;

        colorcolumn = "80";

        wrap = true;
        linebreak = true;
        breakindent = true;
      };

      extraConfigLuaPost = ''
        undodir = { "${config.home.homeDirectory}/.vim/undodir" }

        local refresh_group = vim.api.nvim_create_augroup("refresh_external_changes", { clear = true })
        vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI" }, {
          group = refresh_group,
          callback = function()
            vim.cmd("silent! checktime")
          end,
          desc = "Reload buffers changed by external tools",
        })

        vim.fn.timer_start(500, function()
          vim.cmd("silent! checktime")
        end, { ["repeat"] = -1 })
      '';
    };
  };
}
