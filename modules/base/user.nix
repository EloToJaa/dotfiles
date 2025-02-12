{
  pkgs,
  inputs,
  variables,
  host,
  ...
}: {
  imports = [inputs.home-manager.nixosModules.home-manager];
  home-manager = {
    backupFileExtension = "backup";
    useUserPackages = true;
    useGlobalPkgs = true;
    extraSpecialArgs = {inherit inputs variables host;};
    users.${variables.username} = {
      home = {
        username = "${variables.username}";
        homeDirectory = "/home/${variables.username}";
        stateVersion = "${variables.stateVersion}";
      };
      programs.home-manager.enable = true;
    };
  };

  users.users.${variables.username} = {
    isNormalUser = true;
    description = "${variables.username}";
    group = "${variables.username}";
    extraGroups = ["networkmanager" "wheel" "kvm"];
    shell = pkgs.zsh;
  };

  users.groups.${variables.username} = {
    gid = 1000;
    members = ["${variables.username}"];
  };
  nix.settings.allowed-users = ["${variables.username}"];
}
