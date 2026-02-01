{
  inputs,
  config,
  lib,
  ...
}: let
  inherit (config.settings) homeDirectory;
  cfg = config.modules.base;
in {
  imports = [
    inputs.sops-nix.nixosModules.sops
  ];
  config = lib.mkIf cfg.enable {
    sops = {
      defaultSopsFile = ../../secrets/secrets.yaml;
      defaultSopsFormat = "yaml";

      age.keyFile = "${homeDirectory}/.config/sops/age/keys.txt";
    };
  };
}
