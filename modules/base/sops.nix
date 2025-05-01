{
  inputs,
  pkgs,
  config,
  variables,
  ...
}: {
  imports = [
    inputs.sops-nix.nixosModules.sops
  ];
  sops.defaultSopsFile = ../../secrets/secrets.yaml;
  sops.defaultSopsFormat = "yaml";

  sops.age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";

  sops.secrets = {
    "leetcode/csrftoken" = {
      owner = "${variables.username}";
    };
    "leetcode/session" = {
      owner = "${variables.username}";
    };
    "aoc/session" = {
      owner = "${variables.username}";
    };
  };

  environment.systemPackages = with pkgs; [
    sops
  ];
}
