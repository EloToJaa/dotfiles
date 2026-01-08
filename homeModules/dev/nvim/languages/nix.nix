{
  pkgs,
  inputs,
  config,
  host,
  lib,
  ...
}: let
  cfg = config.modules.dev.nvim.languages.nix;
  flakePath = "${config.home.homeDirectory}/Projects/dotfiles";
in {
  options.modules.dev.nvim.languages.nix = {
    enable = lib.mkEnableOption "Enable nix";
  };
  config = lib.mkIf cfg.enable {
    home.packages = with pkgs.unstable; [
      alejandra
      deadnix
      statix
      nixd
    ];

    nix.nixPath = ["nixpkgs=${inputs.nixpkgs}"];

    programs.nixvim = {
      lsp.servers.nixd = {
        enable = true;
        package = null;
        config = {
          formatting.command = "alejandra";
          nixpkgs.expr = ''import (builtins.getFlake "${flakePath}").inputs.nixpkgs { }'';
          options = {
            nixos.expr = ''(builtins.getFlake "${flakePath}").nixosConfigurations.${host}.options'';
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
