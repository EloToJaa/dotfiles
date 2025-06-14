{
  programs.nvf = {
    enable = true;
    defaultEditor = true;
    enableManpages = true;

    settings.vim = {
      viAlias = false;
      vimAlias = false;

      autopairs.nvim-autopairs.enable = true;
      snippets.luasnip.enable = true;

      notify = {
        nvim-notify.enable = true;
      };

      projects = {
        project-nvim.enable = true;
      };

      notes = {
        todo-comments.enable = true;
      };

      comments.comment-nvim.enable = true;
    };
  };
}
