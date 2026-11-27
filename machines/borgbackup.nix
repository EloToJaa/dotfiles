{
  config,
  lib,
  pkgs,
  ...
}: let
  listCommand = "/run/current-system/sw/bin/borgbackup-list";
  sudoListCommand = pkgs.writeShellScriptBin "borgbackup-list-sudo" ''
    exec /run/wrappers/bin/sudo -n ${listCommand}
  '';
in {
  config = lib.mkIf (config.clan.core.state != {}) {
    # `clan backups list` runs the provider command as the non-root deploy user,
    # which can't read the borgbackup SSH key or repokey.
    clan.core.backups.providers.borgbackup.list = lib.mkForce "borgbackup-list-sudo";

    environment.systemPackages = [sudoListCommand];

    security.sudo.extraRules = [
      {
        groups = ["wheel"];
        commands = [
          {
            command = listCommand;
            options = ["NOPASSWD"];
          }
        ];
      }
    ];
  };
}
