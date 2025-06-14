{config, ...}: {
  programs.nvf.settings.vim = {
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
      undofile = true;

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

luaConfigPost = ''
      undodir = { "${config.home.homeDirectory}/.vim/undodir" }
    '';

    luaConfigPost = ''
      isfname:append("@-@")
    '';
  };
}
