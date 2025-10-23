{
  inputs,
  config,
  lib,
  ...
}: let
  inherit (config.settings) username;
  cfg = config.modules.base;
in {
  imports = [
    inputs.sops-nix.nixosModules.sops
  ];
  config = lib.mkIf cfg.enable {
    sops = {
      defaultSopsFile = ../../secrets/secrets.yaml;
      defaultSopsFormat = "yaml";

      age.keyFile = "/home/${username}/.config/sops/age/keys.txt";
    };
  };
}
