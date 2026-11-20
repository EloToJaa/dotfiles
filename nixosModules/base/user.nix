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
  rex_cfg = config.home-manager.users.${username}.modules.home.rex;
  rex_server = rex_cfg.enable && rex_cfg.server.enable;
in {
  config = lib.mkIf cfg.enable {
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
          inherit stateVersion username homeDirectory;
          enableNixpkgsReleaseCheck = false;
        };
        programs.home-manager.enable = true;
      };
    };

    users = {
      mutableUsers = false;
      users.${username} = {
        isNormalUser = true;
        inherit uid;
        description = username;
        group = username;
        extraGroups = [
          "wheel"
        ];
        shell = pkgs.unstable.zsh;
        # keep the user's systemd services (e.g. the rex server) running after logout
        linger = lib.mkIf rex_server true;
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
