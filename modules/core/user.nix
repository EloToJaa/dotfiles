{ pkgs, inputs, variables, host, system, ...}:
{
  imports = [ inputs.home-manager.nixosModules.home-manager ];
  home-manager = {
    useUserPackages = true;
    useGlobalPkgs = true;
    extraSpecialArgs = { inherit inputs variables host; };
    users.${variables.username} = {
      imports = [ ./../home ];
      home.username = "${variables.username}";
      home.homeDirectory = "/home/${variables.username}";
      home.stateVersion = "24.05";
      programs.home-manager.enable = true;
    };
  };

  users.users.${variables.username} = {
    isNormalUser = true;
    description = "${variables.username}";
    extraGroups = [ "networkmanager" "wheel" "docker" ];
    shell = pkgs.zsh;
  };
  nix.settings.allowed-users = [ "${variables.username}" ];
}
