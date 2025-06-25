{
  pkgs,
  inputs,
  ...
}: {
  home.packages = with pkgs; [
    alejandra
    deadnix
    statix
  ];

  nix.nixPath = ["nixpkgs=${inputs.nixpkgs}"];

  programs.nixvim = {
    lsp.servers.nixd = {
      enable = true;
    };
    plugins = {
      lint.lintersByFt = {
        nix = ["deadnix" "statix"];
      };
      conform-nvim.settings.formatters_by_ft = {
        nix = ["alejandra"];
      };
      treesitter.settings.ensure_installed = [
        "nix"
      ];
    };
  };
}
