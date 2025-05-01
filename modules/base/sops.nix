{
  inputs,
  pkgs,
  config,
  ...
}: {
  imports = [
    inputs.sops-nix.nixosModules.sops
  ];
  sops.defaultSopsFile = ../../secrets/secrets.yaml;
  sops.defaultSopsFormat = "yaml";

  sops.age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";

  sops.secrets = {
    "leetcode/csrftoken" = {};
    "leetcode/session" = {};
    "aoc/session" = {};
  };

  environment.systemPackages = with pkgs; [
    sops
  ];
}
