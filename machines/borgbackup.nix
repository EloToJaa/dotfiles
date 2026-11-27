{
  config,
  lib,
  ...
}: let
  inherit (config.settings) username;
  ownedByDeployUser = {
    owner = username;
    mode = "0400";
  };
in {
  # `clan backups list` runs `borgbackup-list` as the deploy user, which needs the
  # SSH key and repokey. Group-readable keys would make root's ssh reject the key
  # as unprotected, so the deploy user owns them instead.
  clan.core.vars.generators.borgbackup.files = lib.mkIf (config.clan.core.state != {}) {
    "borgbackup.ssh" = ownedByDeployUser;
    "borgbackup.repokey" = ownedByDeployUser;
  };
}
