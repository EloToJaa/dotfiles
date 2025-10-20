{
  pkgs,
  inputs,
  host,
  config,
  ...
}: let
  inherit (config.modules.homelab) groups;
  inherit (config.modules.settings) username stateVersion uid;
in {
  imports = [inputs.home-manager.nixosModules.home-manager];
  home-manager = {
    backupFileExtension = "backup";
    useUserPackages = true;
    useGlobalPkgs = true;
    extraSpecialArgs = {inherit inputs host;};
    users.${username} = {
      home = {
        inherit stateVersion username;
        homeDirectory = "/home/${username}";
        enableNixpkgsReleaseCheck = false;
      };
      programs.home-manager.enable = true;
    };
  };

  users.users.${username} = {
    isNormalUser = true;
    description = username;
    group = username;
    extraGroups = with groups; [
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

  nix.settings.allowed-users = [username];

  users.groups = with groups; {
    ${variables.username} = {
      gid = uid;
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
