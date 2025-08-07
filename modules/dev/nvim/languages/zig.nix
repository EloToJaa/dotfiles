{pkgs, ...}: {
  home.packages = with pkgs.unstable; [
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
