{
  pkgs,
  inputs,
  config,
  host,
  ...
}: let
  flakePath = "${config.home.homeDirectory}/Projects/dotfiles";
in {
  home.packages = with pkgs; [
    alejandra
    deadnix
    statix
  ];

  nix.nixPath = ["nixpkgs=${inputs.nixpkgs}"];

  programs.nixvim = {
    lsp.servers.nixd = {
      enable = true;
      settings = {
        formatting.command = "alejandra";
        nixpkgs.expr = ''import (builtins.getFlake "${flakePath}").inputs.nixpkgs { }'';
        options = {
          nixos.expr = ''(builtins.getFlake "${flakePath}").nixosConfigurations.${host}.options"'';
          home-manager.expr = ''(builtins.getFlake "${flakePath}").nixosConfigurations.${host}.options.home-manager.users.type.getSubOptions []'';
        };
      };
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
