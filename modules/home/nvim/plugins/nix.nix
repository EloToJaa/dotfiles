{
  programs.nixvim = {
    plugins = {
      nix-develop.enable = true;
      which-key.settings.spec = [
        {
          __unkeyed-1 = "<leader>n";
          group = "Nix";
          icon = "";
        }
      ];
    };
    keymaps = [
      {
        mode = "n";
        key = "<leader>nd";
        action = "<cmd>NixDevelop<CR>";
        options.desc = "Develop";
      }
      {
        mode = "n";
        key = "<leader>ns";
        action = "<cmd>NixShell<CR>";
        options.desc = "Shell";
      }
    ];
  };
}
