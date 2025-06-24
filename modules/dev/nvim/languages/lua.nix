{pkgs, ...}: {
  home.packages = with pkgs; [
    lua5_4
    lua54Packages.luarocks
    lua54Packages.luacheck

    stylua
  ];

  programs.nixvim = {
    lsp.servers.lua_ls = {
      enable = true;
    };
    plugins = {
      lint.lintersByFt = {
        lua = ["luacheck"];
      };
      conform-nvim.settings.formatters_by_ft = {
        lua = ["stylua"];
      };
      treesitter.settings.ensure_installed = [
        "lua"
      ];
    };
  };
}
