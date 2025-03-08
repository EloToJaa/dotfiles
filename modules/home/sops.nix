{
  inputs,
  pkgs,
  variables,
  ...
}: {
  imports = [
    inputs.sops-nix.homeManagerModules.sops
  ];
  sops.defaultSopsFile = ../../secrets/leetcode.yaml;
  sops.defaultSopsFormat = "yaml";

  sops.age.keyFile = "/home/${variables.username}/.config/sops/age/keys.txt";

  sops.secrets = {
    "cookies/csrf" = {};
    "cookies/session" = {};
  };

  home.packages = with pkgs; [
    sops
  ];
}
