{
  programs.nixvim.plugins.lualine = {
    enable = true;
    settings = {
      options = {
        section_separators = {
          left = "";
          right = "";
        };
        component_separators = {
          left = "";
          right = "";
        };
      };
      sections = {
        lualine_a = [
          {
            __unkeyed-1 = "mode";
            separator = {
              left = "";
              right = "";
            };
          }
        ];
        lualine_x = ["encoding" "fileformat" "filetype"];
        lualine_z = [
          {
            __unkeyed-1 = "location";
            separator = {
              left = "";
              right = "";
            };
          }
        ];
      };
    };
  };
}
