{
  pkgs,
  inputs,
  host,
  config,
  ...
}: let
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
    extraGroups = [
      "wheel"
      "kvm"
    ];
    shell = pkgs.unstable.zsh;
  };

  nix.settings.allowed-users = [username];

  users.groups.${username} = {
    gid = uid;
    members = [username];
  };
}
