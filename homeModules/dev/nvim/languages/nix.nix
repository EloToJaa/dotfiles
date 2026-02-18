{
  pkgs,
  inputs,
  config,
  settings,
  host,
  lib,
  ...
}: let
  inherit (settings) dotfilesDirectory;
  cfg = config.modules.dev.nvim.languages.nix;
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
          nixpkgs.expr = ''import (builtins.getFlake "${dotfilesDirectory}").inputs.nixpkgs { }'';
          options = {
            nixos.expr = ''(builtins.getFlake "${dotfilesDirectory}").nixosConfigurations.${host}.options'';
            home-manager.expr = ''(builtins.getFlake "${dotfilesDirectory}").nixosConfigurations.${host}.options.home-manager.users.type.getSubOptions []'';
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
