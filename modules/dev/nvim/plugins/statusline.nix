{
  programs.nvf.settings.vim.statusline.lualine = {
    enable = true;
    theme = "catppuccin";

    sectionSeparator = {
      left = "";
      right = "";
    };
    componentSeparator = {
      left = "";
      right = "";
    };

    activeSection = {
      a = [
        ''
          {
          	"mode",
          	separator = { left = "", right = "" },
          }
        ''
      ];
      b = [];
      c = [];
      x = [
        ''{ "encoding" }''
        ''{ "fileformat" }''
        ''{ "filetype" }''
      ];
      y = [];
      z = [
        ''
          {
          	"location",
          	separator = { left = "", right = "" },
          }
        ''
      ];
    };
  };
}
