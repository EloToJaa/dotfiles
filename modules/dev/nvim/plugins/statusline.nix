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
          	separator = { left = "", right = "" }
          }
        ''
      ];
      b = [
        ''
          {
          	"branch",
          	separator = { left = "", right = "" }
          }
        ''
      ];
      c = [
        ''{ "filename" }''
      ];
      x = [
        ''{ "encoding" }''
        ''
          {
            "fileformat"
            separator = { left = "", right = "" }
          }
        ''
        ''
          {
            "filetype"
            separator = { left = "", right = "" }
          }
        ''
      ];
      y = [
        ''
          {
            "progress",
            separator = { left = "", right = "" }
          }
        ''
      ];
      z = [
        ''
          {
          	"location",
          	separator = { left = "", right = "" }
          }
        ''
      ];
    };
  };
}
