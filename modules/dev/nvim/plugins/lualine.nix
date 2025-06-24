{
  programs.nixvim.plugins.lualine = {
    enable = true;
    settings = {
      options = {
        section_separators = { left = ""; right = "" };
				component_separators = { left = ""; right = "" };
      };
      sections = {
        lualine_a = [ "mode" ];
        lualine_x = [ "encoding" "fileformat" "filetype" ];
        lualine_z = [ "location" ];
      };
    };
  };
}
