{
  pkgs,
  inputs,
  host,
  config,
  lib,
  ...
}: let
  inherit (config.settings) username uid homeDirectory;
  inherit (config.clan.core.settings) state-version;
  cfg = config.modules.base;
in {
  config = lib.mkIf cfg.enable {
    clan.core.settings.state-version.enable = true;
    clan.core.vars.generators."${username}-password" = {
      # prompt the user for a password
      # (`password-input` being an arbitrary name)
      prompts.password-input = {
        description = "the ${username} user's password";
        type = "hidden";

        # don't store the prompted password itself
        persist = false;
      };

      # define an output file for storing the hash
      files.password-hash.secret = false;

      # define the logic for generating the hash
      script = ''
        cat $prompts/password-input | mkpasswd -m sha-512 > $out/password-hash
      '';

      share = true;

      # the tools required by the script
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
          inherit username homeDirectory;
          stateVersion = state-version;
          enableNixpkgsReleaseCheck = false;
        };
        programs.home-manager.enable = true;
      };
    };

    users = {
      mutableUsers = false;
      users.${username} = {
        isNormalUser = true;
        description = username;
        group = username;
        extraGroups = [
          "wheel"
          "kvm"
        ];
        shell = pkgs.unstable.zsh;
        hashedPasswordFile =
          config.clan.core.vars.generators."${username}-password".files.password-hash.path;
      };
      groups.${username} = {
        gid = uid;
        members = [username];
      };
    };

    nix.settings.allowed-users = [username];
  };
}
