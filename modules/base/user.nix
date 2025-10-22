{
  pkgs,
  inputs,
  host,
  config,
  lib,
  ...
}: let
  inherit (config.modules.settings) username stateVersion uid;
  cfg = config.modules.base;
in {
  imports = [inputs.home-manager.nixosModules.home-manager];
  config = lib.mkIf cfg.enable {
    home-manager = {
      backupFileExtension = "backup";
      useUserPackages = true;
      useGlobalPkgs = true;
      extraSpecialArgs = {
        inherit inputs host;
        variables = {};
      };
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
  };
}
