{pkgs, ...}: {
  home.packages = with pkgs; [
    zig
  ];

  programs.nixvim = {
    lsp.servers.zls = {
      enable = true;
    };
    plugins = {
      treesitter.settings.ensure_installed = [
        "zig"
      ];
    };
  };
}
