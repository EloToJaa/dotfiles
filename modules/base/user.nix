{
  pkgs,
  inputs,
  variables,
  host,
  ...
}: let
  inherit (variables) homelab;
in {
  imports = [inputs.home-manager.nixosModules.home-manager];
  home-manager = {
    backupFileExtension = "backup";
    useUserPackages = true;
    useGlobalPkgs = true;
    extraSpecialArgs = {inherit inputs variables host;};
    users.${variables.username} = {
      home = {
        inherit (variables) stateVersion username;
        homeDirectory = "/home/${variables.username}";
        enableNixpkgsReleaseCheck = false;
      };
      programs.home-manager.enable = true;
    };
  };

  users.users.${variables.username} = {
    isNormalUser = true;
    description = variables.username;
    group = variables.username;
    extraGroups = with homelab.groups; [
      "wheel"
      "kvm"
      main
      cloud
      media
      photos
      docs
      database
      backups
    ];
    shell = pkgs.unstable.zsh;
  };

  nix.settings.allowed-users = [variables.username];

  users.groups = with homelab.groups; {
    ${variables.username} = {
      gid = 1000;
      members = [variables.username];
    };
    ${main}.gid = 1100;
    ${media}.gid = 1101;
    ${photos}.gid = 1102;
    ${docs}.gid = 1103;
    ${database}.gid = 1104;
    ${backups}.gid = 1105;
    ${cloud}.gid = 1106;
  };
}
