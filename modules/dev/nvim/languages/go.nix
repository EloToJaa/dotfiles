{
  pkgs,
  config,
  ...
}: let
  makeBinPath = pkgs.lib.makeBinPath;
  homeDirectory = config.home.homeDirectory;
in {
  home.packages = with pkgs; [
    go
    gofumpt
  ];

  programs.nixvim = {
    lsp.servers.gopls = {
      enable = true;
    };
    plugins = {
      conform-nvim.settings.formatters_by_ft = {
        go = ["gofumpt"];
      };
      treesitter.settings.ensure_installed = [
        "go"
      ];
    };
  };

  home.sessionVariables = {
    PATH = "${makeBinPath ["${homeDirectory}/go"]}:$PATH";
  };

  programs.nushell.extraEnv = ''
    $env.Path = ($env.Path | prepend ["${makeBinPath ["${homeDirectory}/go"]}"]);
  '';
}
