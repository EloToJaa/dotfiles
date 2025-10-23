{
  pkgs,
  inputs,
  config,
  host,
  lib,
  ...
}: let
  flakePath = "${config.home.homeDirectory}/Projects/dotfiles";
  cfg = config.modules.home.nvim.languages.nix;
in {
  options.modules.home.nvim.languages.nix = {
    enable = lib.mkEnableOption "Enable nix";
  };
  config = lib.mkIf cfg.enable {
    home.packages = with pkgs.unstable; [
      alejandra
      deadnix
      statix
    ];

    nix.nixPath = ["nixpkgs=${inputs.nixpkgs}"];

    programs.nixvim = {
      lsp.servers.nixd = {
        enable = true;
        config = {
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
        treesitter.grammarPackages = with pkgs.unstable.vimPlugins.nvim-treesitter.builtGrammars; [
          nix
        ];
      };
    };
  };
}
