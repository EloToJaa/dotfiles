{
  pkgs,
  inputs,
  variables,
  host,
  ...
}: let
  homelab = variables.homelab;
in {
  imports = [inputs.home-manager.nixosModules.home-manager];
  home-manager = {
    backupFileExtension = "backup";
    useUserPackages = true;
    useGlobalPkgs = true;
    extraSpecialArgs = {inherit inputs variables host;};
    users.${variables.username} = {
      home = {
        username = variables.username;
        homeDirectory = "/home/${variables.username}";
        stateVersion = variables.stateVersion;
      };
      programs.home-manager.enable = true;
    };
  };

  users.users.${variables.username} = {
    isNormalUser = true;
    description = variables.username;
    group = variables.username;
    extraGroups = [
      "networkmanager"
      "wheel"
      "kvm"
      homelab.groups.main
      homelab.groups.media
      homelab.groups.photos
      homelab.groups.docs
      homelab.groups.database
      homelab.groups.backups
    ];
    shell = pkgs.zsh;
  };

  nix.settings.allowed-users = [variables.username];

  users.groups = {
    ${variables.username} = {
      gid = 1000;
      members = [variables.username];
    };
    ${homelab.groups.main}.gid = 1100;
    ${homelab.groups.media}.gid = 1101;
    ${homelab.groups.photos}.gid = 1102;
    ${homelab.groups.docs}.gid = 1103;
    ${homelab.groups.database}.gid = 1104;
    ${homelab.groups.backups}.gid = 1105;
  };
}
