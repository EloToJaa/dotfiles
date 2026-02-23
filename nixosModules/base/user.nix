{
  pkgs,
  inputs,
  host,
  config,
  lib,
  ...
}: let
  inherit (config.settings) username stateVersion uid homeDirectory;
  cfg = config.modules.base;
in {
  config = lib.mkIf cfg.enable {
    clan.core.vars.generators."${username}-password" = {
      prompts.password.description = "${username} password";
      prompts.password.type = "hidden";
      files.hash.secret = false;
      script = "mkpasswd -m sha-512 < $prompts/password > $out/hash";
      runtimeInputs = [pkgs.mkpasswd];
    };

    home-manager = {
      backupFileExtension = "backup";
      useUserPackages = true;
      useGlobalPkgs = true;
      extraSpecialArgs = {
        inherit inputs host;
        inherit (config) settings;
      };
      users.${username} = {
        home = {
          inherit stateVersion username homeDirectory;
          enableNixpkgsReleaseCheck = false;
        };
        programs.home-manager.enable = true;
      };
    };

    users.users.${username} = {
      isNormalUser = true;
      hashedPasswordFile = config.clan.core.vars.generators."${username}-password".files.hash.path;
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
