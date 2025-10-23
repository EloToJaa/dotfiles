{
  inputs,
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.modules.home;
in {
  imports = [
    inputs.sops-nix.homeManagerModules.sops
  ];
  config = lib.mkIf cfg.enable {
    sops = {
      defaultSopsFile = ../../secrets/secrets.yaml;
      defaultSopsFormat = "yaml";

      age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
    };

    home.packages = with pkgs.unstable; [
      sops
    ];
  };
}
